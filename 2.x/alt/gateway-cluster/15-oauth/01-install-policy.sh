#!/bin/bash

CLUSTER1=cluster1
MGMT=mgmt

if [[ -z ${KEYCLOAK_CLIENT} ]]; then
  echo "Have you installed Keycloak?  If so, you may need to expose KEYCLOAK_CLIENT, KEYCLOAK_TOKEN and KEYCLOAK_SECRET"
  exit 1
fi

if [[ -z ${ENDPOINT_HTTPS_GW_CLUSTER1} ]]; then
    my_ip=$(ifconfig en0 | grep "inet " | awk -F'[: ]+' '{ print $2 }')
    echo "Setting up Keycloak and callback APIs on $my_ip"
    export ENDPOINT_KEYCLOAK=$my_ip:18080
    export ENDPOINT_HTTPS_GW_CLUSTER1=$my_ip:8443
fi

kubectl --context ${CLUSTER1} apply -f - <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: oauth
  namespace: httpbin
type: extauth.solo.io/oauth
data:
  client-secret: $(echo -n ${KEYCLOAK_SECRET} | base64)
EOF

kubectl --context ${MGMT} apply -f - <<EOF
apiVersion: security.policy.gloo.solo.io/v2
kind: ExtAuthPolicy
metadata:
  name: httpbin
  namespace: gloo-mesh
spec:
  applyToRoutes:
  - route:
      labels:
        oauth: "true"
  config:
    server:
      name: ext-auth-server
      namespace: gloo-mesh
      cluster: mgmt
    glooAuth:
      configs:
      - oauth2:
          oidcAuthorizationCode:
            appUrl: https://${ENDPOINT_HTTPS_GW_CLUSTER1}
            callbackPath: /callback
            clientId: ${KEYCLOAK_CLIENT}
            clientSecretRef:
              name: oauth
              namespace: httpbin
            issuerUrl: "${KEYCLOAK_URL}/realms/master/"
            session:
              failOnFetchFailure: true
              redis:
                cookieName: keycloak-session
                options:
                  host: redis:6379
            scopes:
            - email
            headers:
              idTokenHeader: jwt
EOF