#!/bin/bash

CLUSTER1=cluster1
MGMT=mgmt

kubectl apply -f 01-gateways-mgmt.yaml --context ${MGMT}
kubectl apply -f 02-gateways-cluster1.yaml --context ${CLUSTER1}