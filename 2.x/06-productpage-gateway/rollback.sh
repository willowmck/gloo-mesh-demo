#!/bin/bash

# Run this after showing off policies
CLUSTER1=cluster1 

kubectl delete -f 02-productpage-cluster1.yaml --context ${CLUSTER1}
kubectl delete -f 01-north-south-gw-cluster1.yaml --context ${CLUSTER1}