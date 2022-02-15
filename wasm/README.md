# Deploying a WASM filter from a ConfigMap

This example uses a prebuilt wasm filter, [hellofilter.wasm](./hellofilter/hellofilter.wasm), which adds a response header.  We will apply this filter to the sidecar running in the Bookinfo reviews-v1 deployment.

## Setup

In order for Gloo Mesh to distribute the wasm filter configuration, we need to create a ConfigMap that adds a custom bootstrap to the proxy.  To apply this in the default namespace of the remote cluster, type the following

```
kubectl apply -f reviews/cluster1/kustomize/gloo-mesh-custom-envoy-bootstrap.yaml
```

Let's also create a ConfigMap for the wasmfilter so the proxy can load it from a volume.

```
kubectl create configmap hellofilter --from-file=hellofilter.wasm=hellofilter/hellofilter.wasm
```

Now, we need to patch the deployment to add some annotations for Istio

```
kubectl patch deployment reviews-v1 --patch-file reviews/cluster1/kustomize/patch-reviews-v1.yaml
```