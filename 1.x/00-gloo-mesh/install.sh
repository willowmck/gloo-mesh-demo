#!/bin/bash

if [[ -z ${GLOO_MESH_LICENSE_KEY} ]]; then
    echo "YOU NEED TO SET ENV VAR GLOO_MESH_LICENSE_KEY!!!!!"
    exit 1
fi 


MGMT=mgmt 
CLUSTER1=cluster1
CLUSTER2=cluster2
export GLOO_MESH_VERSION=v1.2.30

curl -sL https://run.solo.io/meshctl/install | sh -
export PATH=$HOME/.gloo-mesh/bin:$PATH

GLOO_MESH_VERSION=1.2.30

helm repo add gloo-mesh-enterprise https://storage.googleapis.com/gloo-mesh-enterprise/gloo-mesh-enterprise 
helm repo update
kubectl --context ${MGMT} create ns gloo-mesh 
helm upgrade --install gloo-mesh-enterprise gloo-mesh-enterprise/gloo-mesh-enterprise \
--namespace gloo-mesh --kube-context ${MGMT} \
--version=${GLOO_MESH_VERSION} \
--set rbac-webhook.enabled=true \
--set licenseKey=${GLOO_MESH_LICENSE_KEY} \
--set "rbac-webhook.adminSubjects[0].kind=Group" \
--set "rbac-webhook.adminSubjects[0].name=system:masters"
kubectl --context ${MGMT} -n gloo-mesh rollout status deploy/enterprise-networking

sleep 60

#if [[ `kubectl config get-contexts mgmt --no-headers | grep k3d` ]]; then
#  export IP_GLOO_MESH=localhost
#  export ENDPOINT_GLOO_MESH=${IP_GLOO_MESH}:9900
#else
  export IP_GLOO_MESH=`kubectl --context ${MGMT} -n gloo-mesh get svc enterprise-networking -o jsonpath='{.status.loadBalancer.ingress[0].ip}'`
  export ENDPOINT_GLOO_MESH=${IP_GLOO_MESH}:9900
#fi

if [[ -z ${IP_GLOO_MESH} ]]; then
  echo "Maybe you have more patience?"
  exit 1
fi
HOST_GLOO_MESH=$(echo ${ENDPOINT_GLOO_MESH} | cut -d: -f1)

echo "HOST_GLOO_MESH=${HOST_GLOO_MESH}"
echo "ENDPOINT_GLOO_MESH=${ENDPOINT_GLOO_MESH}"

meshctl cluster register --mgmt-context=${MGMT} --remote-context=${CLUSTER1} --relay-server-address=${ENDPOINT_GLOO_MESH} enterprise cluster1 --cluster-domain cluster.local
meshctl cluster register --mgmt-context=${MGMT} --remote-context=${CLUSTER2} --relay-server-address=${ENDPOINT_GLOO_MESH} enterprise cluster2 --cluster-domain cluster.local

sleep 30

kubectl --context ${MGMT} get kubernetescluster -n gloo-mesh

kubectl --context ${CLUSTER1} create namespace gloo-mesh-addons
kubectl --context ${CLUSTER1} label namespace gloo-mesh-addons istio-injection=enabled
kubectl --context ${CLUSTER2} create namespace gloo-mesh-addons
kubectl --context ${CLUSTER2} label namespace gloo-mesh-addons istio-injection=enabled

helm repo add enterprise-agent https://storage.googleapis.com/gloo-mesh-enterprise/enterprise-agent
helm repo update

helm upgrade --install enterprise-agent-addons enterprise-agent/enterprise-agent \
  --kube-context=${CLUSTER1} \
  --version=${GLOO_MESH_VERSION} \
  --namespace gloo-mesh-addons \
  --set enterpriseAgent.enabled=false \
  --set rate-limiter.enabled=true \
  --set ext-auth-service.enabled=true

helm upgrade --install enterprise-agent-addons enterprise-agent/enterprise-agent \
  --kube-context=${CLUSTER2} \
  --version=${GLOO_MESH_VERSION} \
  --namespace gloo-mesh-addons \
  --set enterpriseAgent.enabled=false \
  --set rate-limiter.enabled=true \
  --set ext-auth-service.enabled=true

kubectl apply --context ${MGMT} -f- <<EOF
apiVersion: networking.mesh.gloo.solo.io/v1
kind: AccessPolicy
metadata:
  namespace: gloo-mesh
  name: gloo-mesh-addons
spec:
  sourceSelector:
  - kubeServiceAccountRefs:
      serviceAccounts:
        - name: istio-ingressgateway-service-account
          namespace: istio-system
          clusterName: cluster1
        - name: istio-ingressgateway-service-account
          namespace: istio-system
          clusterName: cluster2
  - kubeIdentityMatcher:
      namespaces:
      - gloo-mesh-addons
  destinationSelector:
  - kubeServiceMatcher:
      namespaces:
      - gloo-mesh-addons
EOF