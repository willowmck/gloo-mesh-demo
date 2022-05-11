#!/bin/bash

CLUSTER1=cluster1 
CLUSTER2=cluster2 
MGMT=mgmt 

kubectl --context ${CLUSTER1} delete -f https://raw.githubusercontent.com/istio/istio/1.11.5/samples/bookinfo/networking/bookinfo-gateway.yaml
kubectl --context ${CLUSTER2} delete -f https://raw.githubusercontent.com/istio/istio/1.11.5/samples/bookinfo/networking/bookinfo-gateway.yaml

kubectl --context ${MGMT} apply -f - <<EOF
apiVersion: networking.enterprise.mesh.gloo.solo.io/v1beta1
kind: VirtualGateway
metadata:
  name: bookinfo-virtualgateway
  namespace: gloo-mesh
spec:
  connectionHandlers:
  - http:
      routeConfig:
      - virtualHostSelector:
          namespaces:
          - "gloo-mesh"
  ingressGatewaySelectors:
  - portName: http2
    destinationSelectors:
    - kubeServiceMatcher:
        clusters:
        - cluster1
        - cluster2
        labels:
          istio: ingressgateway
        namespaces:
        - istio-system
EOF

kubectl --context ${MGMT} apply -f - <<EOF
apiVersion: networking.enterprise.mesh.gloo.solo.io/v1beta1
kind: VirtualHost
metadata:
  name: bookinfo-virtualhost
  namespace: gloo-mesh
spec:
  domains:
  - '*'
  routes:
  - matchers:
    - uri:
        prefix: /
    delegateAction:
      selector:
        namespaces:
        - "gloo-mesh"
EOF

kubectl --context ${MGMT} apply -f - <<EOF
apiVersion: networking.enterprise.mesh.gloo.solo.io/v1beta1
kind: RouteTable
metadata:
  name: bookinfo-routetable
  namespace: gloo-mesh
spec:
  routes:
  - matchers:
    - uri:
        exact: /productpage
    - uri:
        prefix: /static
    - uri:
        exact: /login
    - uri:
        exact: /logout
    - uri:
        prefix: /api/v1/products
    name: productpage
    routeAction:
      destinations:
      - kubeService:
          clusterName: cluster1
          name: productpage
          namespace: default
EOF