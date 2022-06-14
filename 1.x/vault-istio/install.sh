#!/bin/bash

CLUSTER1=cluster1 
CLUSTER2=cluster2 
MGMT=mgmt 

helm repo add hashicorp https://helm.releases.hashicorp.com

openssl req -new -newkey rsa:4096 -x509 -sha256 \
    -days 3650 -nodes -out root-cert.pem -keyout root-key.pem \
    -subj "/O=my-org"

for cluster in ${CLUSTER1} ${CLUSTER2}; do

  # For more info about Vault in Kubernetes, see the Vault docs: https://learn.hashicorp.com/tutorials/vault/kubernetes-cert-manager

  # Install Vault in dev mode
  helm install -n vault  vault hashicorp/vault --version=0.20.1 --set "injector.enabled=false" --set "server.dev.enabled=true" --kube-context="${cluster}" --create-namespace

  sleep 30

  # Wait for Vault to come up.
  # Don't use 'kubectl rollout' because Vault is a statefulset without a rolling deployment.
  kubectl --context="${cluster}" wait --for=condition=Ready -n vault pod/vault-0

  # Enable Vault auth for Kubernetes.
  kubectl --context="${cluster}" exec -n vault vault-0 -- /bin/sh -c 'vault auth enable kubernetes'

  # Set the Kubernetes Auth config for Vault to the mounted token.
  kubectl --context="${cluster}" exec -n vault vault-0 -- /bin/sh -c 'vault write auth/kubernetes/config \
    token_reviewer_jwt="$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" \
    kubernetes_host="https://$KUBERNETES_PORT_443_TCP_ADDR:443" \
    kubernetes_ca_cert=@/var/run/secrets/kubernetes.io/serviceaccount/ca.crt'

  # Bind the istiod service account to the PKI policy.
  kubectl --context="${cluster}" exec -n vault vault-0 -- /bin/sh -c 'vault write auth/kubernetes/role/gen-int-ca-istio \
    bound_service_account_names=istiod \
    bound_service_account_namespaces=istio-system \
    policies=gen-int-ca-istio \
    ttl=2400h'

  # Initialize the Vault PKI.
  kubectl --context="${cluster}" exec -n vault vault-0 -- /bin/sh -c 'vault secrets enable pki'

  # Set the Vault CA to the pem_bundle.
  kubectl --context="${cluster}" exec -n vault vault-0 -- /bin/sh -c "vault write -format=json pki/config/ca pem_bundle=\"$(cat root-key.pem root-cert.pem)\""

  # Initialize the Vault intermediate cert path.
  kubectl --context="${cluster}" exec -n vault vault-0 -- /bin/sh -c 'vault secrets enable -path pki_int pki'

  # Set the policy for the intermediate cert path.
  kubectl --context="${cluster}" exec -n vault vault-0 -- /bin/sh -c 'vault policy write gen-int-ca-istio - <<EOF
path "pki_int/*" {
capabilities = ["create", "read", "update", "delete", "list"]
}
path "pki/cert/ca" {
capabilities = ["read"]
}
path "pki/root/sign-intermediate" {
capabilities = ["create", "read", "update", "list"]
}
EOF'

done

# Remove cert and key
rm root-cert.pem
rm root-key.pem

# Update the VirtualMesh
kubectl --context ${MGMT} apply -f - <<EOF
apiVersion: networking.mesh.gloo.solo.io/v1
kind: VirtualMesh
metadata:
  name: virtual-mesh
  namespace: gloo-mesh
spec:
  mtlsConfig:
    # Note: Do NOT use this autoRestartPods setting in production!!
    autoRestartPods: true
    shared:
      intermediateCertificateAuthority:
        vault:
          # Vault path to the CA endpoint
          caPath: "pki/root/sign-intermediate"
          # Vault path to the CSR endpoint
          csrPath: "pki_int/intermediate/generate/exported"
          # Vault server endpoint
          server: "http://vault.vault:8200"
          # Auth mechanism to use
          kubernetesAuth:
            role: "gen-int-ca-istio"
  federation:
    # federate all Destinations to all external meshes
    selectors:
    - {}
  meshes:
  - name: istiod-istio-system-cluster1
    namespace: gloo-mesh
  - name: istiod-istio-system-cluster2
    namespace: gloo-mesh
EOF

# Update the enterprise agents to enable RBAC

for cluster in ${CLUSTER1} ${CLUSTER2}; do
  helm get values -n gloo-mesh enterprise-agent --kube-context="${cluster}" > $cluster-values.yaml
  echo "istiodSidecar: " >> $cluster-values.yaml
  echo "  createRoleBinding: true" >> $cluster-values.yaml
  echo "  istiodServiceAccount:" >> $cluster-values.yaml
  echo "    name: istiod" >> $cluster-values.yaml
  echo "    namespace: istio-system" >> $cluster-values.yaml
  helm upgrade -n gloo-mesh enterprise-agent enterprise-agent/enterprise-agent --kube-context="${cluster}" --version=$GLOO_MESH_VERSION -f $cluster-values.yaml
  rm $cluster-values.yaml
done

sleep 30

# Update Istio deployments
export MGMT_PLANE_VERSION=$(meshctl version | jq '.server[].components[] | select(.componentName == "enterprise-networking") | .images[] | select(.name == "enterprise-networking") | .version')


kubectl --context ${CLUSTER1} apply -f istio-cluster1.yaml
kubectl --context ${CLUSTER2} apply -f istio-cluster2.yaml

# Restart Istiod
for cluster in ${CLUSTER1} ${CLUSTER2}; do
  kubectl --context "${cluster}" -n istio-system patch deployment istiod -p "{\"spec\":{\"template\":{\"metadata\":{\"labels\":{\"date\":\"`date +'%s'`\"}}}}}"
done

sleep 30
echo "Checking to ensure that the cacert secret is gone.  If all is good you should not see any further output"
for cluster in ${CLUSTER1} ${CLUSTER2}; do
  kubectl --context="${cluster}" get cm -n default istio-ca-root-cert -ojson | jq -r  '.data["root-cert.pem"]' | diff root-cert.pem -
done
