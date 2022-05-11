#!/bin/bash

MGMT=mgmt

kubectl --context ${MGMT} apply -f 01-ratings-fault-injection.yaml
kubectl --context ${MGMT} apply -f 02-reviews-request-timeout.yaml