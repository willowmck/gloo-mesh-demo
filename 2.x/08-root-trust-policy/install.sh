#!/bin/bash

# Run this after showing off policies
MGMT=mgmt

./00-explore.sh 

echo ""
echo "Applying root trust policy" 

kubectl apply -f 01-root-trust-policy-mgmt.yaml --context ${MGMT}

sleep 30

echo ""
echo "Inspecting certificates"
./02-explore.sh

# For demos, we won't use a secure gateway