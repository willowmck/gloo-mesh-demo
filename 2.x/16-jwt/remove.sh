#!/bin/bash

CLUSTER1=cluster1 

kubectl --context ${CLUSTER1} delete jwtpolicy httpbin -n httpbin
kubectl --context ${CLUSTER1} delete externalservice keycloak -n httpbin
kubectl --context ${CLUSTER1} delete externalendpoint keycloak -n httpbin 