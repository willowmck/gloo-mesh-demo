#!/bin/bash

MGMT=mgmt 

kubectl --context ${MGMT} delete -f 01-simple.yaml