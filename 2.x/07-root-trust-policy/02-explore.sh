#!/bin/bash

CLUSTER1=cluster1 
CLUSTER2=cluster2 

echo "CLUSTER1 cacerts"
kubectl --context ${CLUSTER1} get secret -n istio-system cacerts -o yaml

echo ""
echo "CLUSTER2 cacerts"
kubectl --context ${CLUSTER2} get secret -n istio-system cacerts -o yaml

echo ""
echo "CLUSTER1 showcerts between reviews and ratings"
echo "----------------------------------------------"
kubectl --context ${CLUSTER1} exec -t -n bookinfo-backends deploy/reviews-v1 \
-- openssl s_client -showcerts -connect ratings:9080 -alpn istio

echo ""
echo "CLUSTER2 showcerts between reviews and ratings"
echo "----------------------------------------------"
kubectl --context ${CLUSTER2} exec -t -n bookinfo-backends deploy/reviews-v1 \
-- openssl s_client -showcerts -connect ratings:9080 -alpn istio

kubectl --context ${CLUSTER1} -n httpbin rollout restart deploy/in-mesh