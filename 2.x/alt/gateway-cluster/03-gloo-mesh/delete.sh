#!/bin/bash

CLUSTER1=cluster1
CLUSTER2=cluster2
MGMT=mgmt

helm delete gloo-mesh-agent-addons -n gloo-mesh-addons --kube-context=${CLUSTER2} 
helm delete gloo-mesh-agent-addons -n gloo-mesh-addons --kube-context=${CLUSTER1} 


kubectl --context ${CLUSTER2} delete namespace gloo-mesh-addons
kubectl --context ${CLUSTER1} delete namespace gloo-mesh-addons


helm delete gloo-mesh-agent -n gloo-mesh --kube-context=${CLUSTER2} 
kubectl delete secret relay-identity-token-secret -n gloo-mesh --context ${CLUSTER2}
kubectl delete secret relay-root-tls-secret -n gloo-mesh --context ${CLUSTER2}
kubectl --context ${CLUSTER2} delete ns gloo-mesh
kubectl delete kubernetescluster cluster2 -n gloo-mesh --context ${MGMT}

helm delete gloo-mesh-agent -n gloo-mesh --kube-context=${CLUSTER1} 
kubectl delete secret relay-identity-token-secret -n gloo-mesh --context ${CLUSTER1}
kubectl delete secret relay-root-tls-secret -n gloo-mesh --context ${CLUSTER1}
kubectl --context ${CLUSTER1} delete ns gloo-mesh
kubectl delete kubernetescluster cluster1 -n gloo-mesh --context ${MGMT}

helm delete gloo-mesh-enterprise -n gloo-mesh --kube-context ${MGMT}