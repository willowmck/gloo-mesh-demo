#!/bin/bash

# Run this after showing off policies
MGMT=mgmt

kubectl delete -f 01-root-trust-policy-mgmt.yaml --context ${MGMT}