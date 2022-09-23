# Alternate Demo: Gateway Cluster

**WIP**

This demo showcases a tiered gateway installation where **cluster3** is setup to handle API gateway functions.  The other two clusters (*cluster1* and *cluster2*) both will have Istio installed but will function as workload clusters only accepting traffic over the east/west gateway.

Note that the above is just a practical matter of not utilizing the ingress gateways on **cluster1** and **cluster2** as they will still be created and exposed on the normal ports.