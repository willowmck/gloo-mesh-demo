#!/bin/bash

MGMT=mgmt

kubectl delete -f 02-default-mgmt.yaml --context ${MGMT}
kubectl delete -f 01-default-mgmt.yaml --context ${MGMT}