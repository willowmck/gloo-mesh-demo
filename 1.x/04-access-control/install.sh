#!/bin/bash

MGMT=mgmt 

kubectl --context ${MGMT} apply -f 01-virtual-mesh-mgmt.yaml
kubectl --context ${MGMT} apply -f 02-istio-ingressgateway-mgmt.yaml
kubectl --context ${MGMT} apply -f 03-productpage-mgmt.yaml
kubectl --context ${MGMT} apply -f 04-reviews-mgmt.yaml