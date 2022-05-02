#!/bin/bash

CLUSTER1=cluster1
CLUSTER2=cluster2

bookinfo_yaml=https://raw.githubusercontent.com/istio/istio/1.11.4/samples/bookinfo/platform/kube/bookinfo.yaml
kubectl --context ${CLUSTER1} label namespace default istio-injection=enabled
# deploy bookinfo application components for all versions less than v3
kubectl --context ${CLUSTER1} apply -f ${bookinfo_yaml} -l 'app,version notin (v3)'
# deploy all bookinfo service accounts
kubectl --context ${CLUSTER1} apply -f ${bookinfo_yaml} -l 'account'
# configure ingress gateway to access bookinfo
kubectl --context ${CLUSTER1} apply -f https://raw.githubusercontent.com/istio/istio/1.11.4/samples/bookinfo/networking/bookinfo-gateway.yaml

sleep 30
kubectl --context ${CLUSTER1} get pods

kubectl --context ${CLUSTER2} label namespace default istio-injection=enabled
# deploy all bookinfo service accounts and application components for all versions
kubectl --context ${CLUSTER2} apply -f ${bookinfo_yaml}
# configure ingress gateway to access bookinfo
kubectl --context ${CLUSTER2} apply -f https://raw.githubusercontent.com/istio/istio/1.11.4/samples/bookinfo/networking/bookinfo-gateway.yaml

sleep 30
kubectl --context ${CLUSTER2} get pods

