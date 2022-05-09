#!/bin/bash

CLUSTER1=cluster1 

kubectl --context ${CLUSTER1} apply -f 01-httpbin-cluster1.yaml
kubectl --context ${CLUSTER1} apply -f 02-httpbin-cluster1.yaml
kubectl --context ${CLUSTER1} apply -f 03-httpbin-cluster1.yaml
kubectl --context ${CLUSTER1} apply -f 04-rate-limit-server-cluster1.yaml
kubectl --context ${CLUSTER1} apply -f 05-httpbin-cluster1.yaml
