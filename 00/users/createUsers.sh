#!/bin/sh

users=(irene david)

# Create CSRs for Irene (InfoSec) and David (DevOps)
for user in ${users[@]}; do
    openssl genrsa -out $user.key 2048
done

openssl req -new -key irene.key -out irene.csr -subj "/O=infosec/CN=irene"
openssl req -new -key david.key -out david.csr -subj "/O=devops/CN=david"

cat <<EOF | kubectl apply -f -
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  # This has to match the id that you will use
  name: irene
spec:
  groups:
  # This means we want to add this csr to all of the authenticated users
  - system:authenticated
  request: $(cat irene.csr | base64 | tr -d "\n")
  signerName: kubernetes.io/kube-apiserver-client
  usages:
  - client auth
EOF

cat <<EOF | kubectl apply -f -
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  # This has to match the id that you will use
  name: david
spec:
  groups:
  # This means we want to add this csr to all of the authenticated users
  - system:authenticated
  request: $(cat david.csr | base64 | tr -d "\n")
  signerName: kubernetes.io/kube-apiserver-client
  usages:
  - client auth
EOF

for user in ${users[@]}; do
    kubectl certificate approve $user 
    kubectl get csr/$user -o jsonpath="{.status.certificate}" | base64 -d > $user.crt 
done

cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: infosec-binding 
subjects:
- kind: Group 
  name: infosec 
  apiGroup: rbac.authorization.k8s.io 
roleRef:
  kind: ClusterRole 
  name: cluster-admin
  apiGroup: rbac.authorization.k8s.io
EOF

cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: devops-binding 
subjects:
- kind: Group 
  name: devops 
  apiGroup: rbac.authorization.k8s.io 
roleRef:
  kind: ClusterRole 
  name: cluster-admin
  apiGroup: rbac.authorization.k8s.io
EOF

for user in ${users[@]}; do
    kubectl config set-credentials $user --client-key=$user.key --client-certificate=$user.crt --embed-certs=true
    kubectl config set-context ${user}Mgmt --cluster=mgmt --user=${user}
done