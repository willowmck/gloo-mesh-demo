#!/bin/bash

MGMT=mgmt
CLUSTER1=cluster1

kubectl --context ${CLUSTER1} delete -f 02-httpbin-cluster1.yaml
kubectl --context ${MGMT} delete -f 01-httpbin-mgmt.yaml