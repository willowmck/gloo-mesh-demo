#!/bin/bash

CLUSTER1=cluster1 

kubectl apply -f 01-bookinfo-cluster1.yaml --context ${CLUSTER1}
kubectl apply -f 02-reviews-cluster1.yaml --context ${CLUSTER1}