#!/bin/bash

MGMT=mgmt 
current=$(kubectl config current-context)
kubectl --context ${MGMT} create namespace keycloak
kubectl --context ${MGMT} -n keycloak apply -f keycloak.yaml

sleep 30
kubectl --context ${MGMT} -n keycloak rollout status deploy/keycloak

kubectl config use-context ${MGMT}
nodes=$(kubectl get nodes --no-headers -oname | cut -d '/' -f2)

echo $nodes | grep k3d

if [[ $? == 0 ]]; then
    echo "Using k3d I see. Exposing keycloak on port 18080"
    node=$(k3d node list | grep mgmt | grep loadbalancer | cut -f1 -d ' ')
    echo "Editing node $node"
    k3d node edit $node --port-add 18080:8080
    my_ip=$(ifconfig en0 | grep "inet " | awk -F'[: ]+' '{ print $2 }')
    export ENDPOINT_KEYCLOAK=$my_ip:18080
    export ENDPOINT_HTTPS_GW_CLUSTER1=$my_ip:8443
else
    export ENDPOINT_KEYCLOAK=$(kubectl --context ${MGMT} -n keycloak get service keycloak -o jsonpath='{.status.loadBalancer.ingress[0].*}'):8080
fi
export HOST_KEYCLOAK=$(echo ${ENDPOINT_KEYCLOAK} | cut -d: -f1)
export PORT_KEYCLOAK=$(echo ${ENDPOINT_KEYCLOAK} | cut -d: -f2)
export KEYCLOAK_URL=http://${ENDPOINT_KEYCLOAK}/auth

export KEYCLOAK_TOKEN=$(curl -d "client_id=admin-cli" -d "username=admin" -d "password=admin" -d "grant_type=password" \
    "$KEYCLOAK_URL/realms/master/protocol/openid-connect/token" | jq -r .access_token)

# Create initial token to register the client
read -r client token <<<$(curl -H "Authorization: Bearer ${KEYCLOAK_TOKEN}" -X POST -H "Content-Type: application/json" \
    -d '{"expiration": 0, "count": 1}' $KEYCLOAK_URL/admin/realms/master/clients-initial-access | jq -r '[.id, .token] | @tsv')
export KEYCLOAK_CLIENT=${client}

# Register the client
read -r id secret <<<$(curl -X POST -d "{ \"clientId\": \"${KEYCLOAK_CLIENT}\" }" -H "Content-Type:application/json" \
    -H "Authorization: bearer ${token}" ${KEYCLOAK_URL}/realms/master/clients-registrations/default| jq -r '[.id, .secret] | @tsv')
export KEYCLOAK_SECRET=${secret}

# Add allowed redirect URIs
curl -H "Authorization: Bearer ${KEYCLOAK_TOKEN}" -X PUT -H "Content-Type: application/json" \
    -d '{"serviceAccountsEnabled": true, "directAccessGrantsEnabled": true, "authorizationServicesEnabled": true, "redirectUris": ["'https://${ENDPOINT_HTTPS_GW_CLUSTER1}'/callback"]}' \
    $KEYCLOAK_URL/admin/realms/master/clients/${id}

# Add the group attribute in the JWT token returned by Keycloak
curl -H "Authorization: Bearer ${KEYCLOAK_TOKEN}" -X POST -H "Content-Type: application/json" -d '{"name": "group", "protocol": "openid-connect", "protocolMapper": "oidc-usermodel-attribute-mapper", "config": {"claim.name": "group", "jsonType.label": "String", "user.attribute": "group", "id.token.claim": "true", "access.token.claim": "true"}}' $KEYCLOAK_URL/admin/realms/master/clients/${id}/protocol-mappers/models

# Create first user
curl -H "Authorization: Bearer ${KEYCLOAK_TOKEN}" -X POST -H "Content-Type: application/json" -d '{"username": "user1", "email": "user1@example.com", "enabled": true, "attributes": {"group": "users"}, "credentials": [{"type": "password", "value": "password", "temporary": false}]}' $KEYCLOAK_URL/admin/realms/master/users

# Create second user
curl -H "Authorization: Bearer ${KEYCLOAK_TOKEN}" -X POST -H "Content-Type: application/json" -d '{"username": "user2", "email": "user2@solo.io", "enabled": true, "attributes": {"group": "users"}, "credentials": [{"type": "password", "value": "password", "temporary": false}]}' $KEYCLOAK_URL/admin/realms/master/users

kubectl config use-context $current

echo "You should export the following variables!"
echo "export KEYCLOAK_SECRET=$KEYCLOAK_SECRET"
echo "export KEYCLOAK_CLIENT=$KEYCLOAK_CLIENT"
echo "export KEYCLOAK_URL=$KEYCLOAK_URL"
echo "export ENDPOINT_HTTPS_GW_CLUSTER1=$ENDPOINT_HTTPS_GW_CLUSTER1"