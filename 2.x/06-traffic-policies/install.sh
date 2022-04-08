#!/bin/bash

# Run this after showing off policies
CLUSTER1=cluster1 

kubectl apply -f 01-ratings-fault-injection-cluster1.yaml --context ${CLUSTER1}
kubectl apply -f 02-ratings-cluster1.yaml --context ${CLUSTER1}
kubectl apply -f 03-reviews-request-timeout-cluster1.yaml --context ${CLUSTER1}
kubectl apply -f 04-reviews-cluster1.yaml --context ${CLUSTER1}