#!/bin/bash

MGMT=mgmt 

kubectl --context ${MGMT} -n gloo-mesh delete virtualdestination reviews-global
kubectl --context ${MGMT} -n gloo-mesh delete trafficpolicy reviews-shift-failover