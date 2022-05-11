#!/bin/bash

MGMT=mgmt

kubectl --context ${MGMT} delete -f 02-reviews-request-timeout.yaml
kubectl --context ${MGMT} delete -f 01-ratings-fault-injection.yaml