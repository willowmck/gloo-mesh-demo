#!/bin/bash

CLUSTER1=cluster1
MGMT=mgmt

kubectl delete -f 04-bookinfo-cluster1.yaml --context ${CLUSTER1}
kubectl delete -f 03-gateways-cluster1.yaml --context ${CLUSTER1}
kubectl delete -f 02-bookinfo-mgmt.yaml --context ${MGMT}
kubectl delete -f 01-gateways-mgmt.yaml --context ${MGMT}