#!/bin/bash

MGMT=mgmt
CLUSTER1=cluster1

kubectl --context ${MGMT} apply -f 01-httpbin-mgmt.yaml
kubectl --context ${CLUSTER1} apply -f 02-httpbin-cluster1.yaml