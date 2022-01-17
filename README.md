# Gloo Mesh Enterprise Demo

This repository contains definitions for a scripted walkthrough of Gloo Mesh Enterprise features.  The current demo is based on Gloo Mesh 1.2.  Stay tuned for 1.3 features.

## Pre-requisites
This demo assumes that you have a 3-cluster setup and that your kube context names are `mgmt`, `cluster` and `cluster2`.  No other assumptions about your platform are made, but you should have the authority to create external load balancers so that your ingress gateways are accessible.

You should also have Gloo Mesh Enterprise installed on the management plane and Istio 1.11.4 installed on both remote clusters.  For more information on how that's done see our [docs](https://docs.solo.io/gloo-mesh-enterprise/latest/setup/installation/).

Each remote cluster should be [registered](https://docs.solo.io/gloo-mesh-enterprise/latest/setup/enterprise_cluster_registration/) with the management plane.

We also assume that you have the bookinfo application installed on both remote clusters.  We will use the setup below.

![Gloo Mesh](images/initial-setup.png)