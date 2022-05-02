#!/bin/bash

CLUSTER1=cluster1
MGMT=mgmt

kubectl apply -f 01-bookinfo-mgmt.yaml --context ${MGMT}
kubectl apply -f 02-bookinfo-cluster1.yaml --context ${CLUSTER1}

