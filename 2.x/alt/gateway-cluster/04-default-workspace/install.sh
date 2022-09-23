#!/bin/bash

MGMT=mgmt

kubectl apply -f 01-default-mgmt.yaml --context ${MGMT}
kubectl apply -f 02-default-mgmt.yaml --context ${MGMT}