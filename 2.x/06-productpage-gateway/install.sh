#!/bin/bash

# Run this after showing off policies
CLUSTER1=cluster1 

kubectl apply -f 01-north-south-gw-cluster1.yaml --context ${CLUSTER1}
kubectl apply -f 02-productpage-cluster1.yaml --context ${CLUSTER1}

# For demos, we won't use a secure gateway