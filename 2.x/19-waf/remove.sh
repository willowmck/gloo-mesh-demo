#!/bin/bash

CLUSTER1=cluster1 

kubectl --context ${CLUSTER1} apply -f 03-orig-rt.yaml
kubectl --context ${CLUSTER1} delete -f 01-log4shell-cluster1.yaml