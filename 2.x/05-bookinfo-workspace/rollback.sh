#!/bin/bash

CLUSTER1=cluster1
MGMT=mgmt

kubectl delete -f 02-bookinfo-cluster1.yaml --context ${CLUSTER1}
kubectl delete -f 01-bookinfo-mgmt.yaml --context ${MGMT}