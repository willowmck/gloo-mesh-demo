#!/bin/bash

CLUSTER1=cluster1 

kubectl delete -f 02-reviews-cluster1.yaml --context ${CLUSTER1}
kubectl delete -f 01-bookinfo-cluster1.yaml --context ${CLUSTER1}