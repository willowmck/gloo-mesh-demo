#!/bin/bash

CLUSTER1=cluster1 

kubectl --context ${CLUSTER1} delete extauthpolicy httpbin -n httpbin 
kubectl --context ${CLUSTER1} delete configmap allow-solo-email-users -n httpbin 

kubectl --context ${CLUSTER1} apply -f - <<EOF
apiVersion: networking.gloo.solo.io/v2
kind: RouteTable
metadata:
  name: httpbin
  namespace: httpbin
  labels:
    expose: "true"
spec:
  hosts:
    - '*'
  virtualGateways:
    - name: north-south-gw
      namespace: istio-gateways
      cluster: cluster1
  workloadSelectors: []
  http:
    - name: httpbin
      matchers:
      - uri:
          exact: /get
      forwardTo:
        destinations:
        - ref:
            name: in-mesh
            namespace: httpbin
          port:
            number: 8000
EOF

kubectl --context ${CLUSTER1} delete extauthserver ext-auth-server -n httpbin 
kubectl --context ${CLUSTER1} delete secret oauth -n httpbin 