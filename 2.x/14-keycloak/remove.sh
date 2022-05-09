#!/bin/bash

MGMT=mgmt 

kubectl --context ${MGMT} -n keycloak delete -f keycloak.yaml
kubectl --context ${MGMT} delete namespace keycloak