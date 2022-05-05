#/bin/bash

CLUSTER1=cluster1

kubectl delete -f 02-reviews-cluster1.yaml --context ${CLUSTER1}