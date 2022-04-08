#!/bin/bash

CLUSTER1=cluster1
MGMT=mgmt

kubectl apply -f 01-gateways-mgmt.yaml --context ${MGMT}
kubectl apply -f 02-bookinfo-mgmt.yaml --context ${MGMT}
kubectl apply -f 03-gateways-cluster1.yaml --context ${CLUSTER1}
kubectl apply -f 04-bookinfo-cluster1.yaml --context ${CLUSTER1}