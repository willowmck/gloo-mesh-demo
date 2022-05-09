#!/bin/bash

CLUSTER1=cluster1 

kubectl --context ${CLUSTER1} apply -f 01-log4shell-cluster1.yaml
kubectl --context ${CLUSTER1} apply -f 02-httpbin-cluster1.yaml