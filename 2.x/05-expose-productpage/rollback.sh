#!/bin/bash

CLUSTER1=cluster1
CLUSTER2=cluster2

kubectl delete -f 04-north-south-gw-cluster1.yaml --context ${CLUSTER1}

kubectl delete secret tls-secret -n istio-gateways --context ${CLUSTER2}
kubectl delete secret tls-secret -n istio-gateways --context ${CLUSTER1}

rm tls.crt 
rm tls.key 

kubectl delete -f 02-productpage-cluster1.yaml --context ${CLUSTER1}