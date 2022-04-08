#!/bin/bash

CLUSTER1=cluster1
CLUSTER2=cluster2

kubectl apply -f 01-north-south-gw-cluster1.yaml --context ${CLUSTER1}
kubectl apply -f 02-productpage-cluster1.yaml --context ${CLUSTER1}

./03-secure-gw.sh

kubectl apply -f 04-north-south-gw-cluster1.yaml --context ${CLUSTER1}
