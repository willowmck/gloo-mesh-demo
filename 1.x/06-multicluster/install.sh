#!/bin/bash

MGMT=mgmt 

kubectl --context ${MGMT} apply -f 01-simple.yaml
kubectl --context ${MGMT} apply -f 02-reviews.yaml