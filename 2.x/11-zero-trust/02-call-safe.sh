#!/bin/bash

CLUSTER1=cluster1
kubectl get ns | grep foo
if [[ $? == 1 ]]; then
    kubectl --context ${CLUSTER1} create ns foo
    kubectl --context ${CLUSTER1} label ns foo istio.io/rev=1-13

    echo "Deployng sleep into namespace foo"
    kubectl --context ${CLUSTER1} apply -f sleep.yaml -n foo

    sleep 20
fi

#kubectl --context ${CLUSTER1} -n httpbin debug -i -q ${pod} --image=curlimages/curl -- curl -s -o /dev/null -w "%{http_code}" \
#    http://reviews.bookinfo-backends.svc.cluster.local:9080/reviews/0

echo ""
echo "Using sleep to curl reviews"
echo ""
kubectl --context ${CLUSTER1} exec "$(kubectl --context ${CLUSTER1} get pod -l app=sleep -n foo -o jsonpath={.items..metadata.name})" \
    -c sleep -n foo -- curl -s -w "%{http_code}" http://reviews.bookinfo-backends.svc.cluster.local:9080/reviews/0