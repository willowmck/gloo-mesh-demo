#!/bin/bash

# Run this after showing off policies
CLUSTER1=cluster1 

kubectl delete -f 04-reviews-cluster1.yaml --context ${CLUSTER1}
kubectl delete -f 03-reviews-request-timeout-cluster1.yaml --context ${CLUSTER1}
kubectl delete -f 02-ratings-cluster1.yaml --context ${CLUSTER1}
kubectl delete -f 01-ratings-fault-injection-cluster1.yaml --context ${CLUSTER1}