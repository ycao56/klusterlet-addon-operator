# IBM metering service helm chart

## Introduction 

This chart deploys the IBM metering service that can be used to view and download detailed usage metrics for your applications and cluster.  
**The metering service chart should only be deployed once per cluster, must be named "metering", and must be installed into the kube-system namespace.**

## Chart Details
This chart includes
  - Deployments of the metering data manager and user interface services;
  - Daemonset of the metering reader service;
  - Ingress configurations for the metering services;

## Prerequisites

None

## PodSecurityPolicy Requirements 

## Red Hat OpenShift SecurityContextConstraints Requirements

## Resources Required

Metering uses the IBM MongoDB service.

## Installing the Chart

To install the chart with the release name `metering`:

```console
$ helm repo add mgmt-charts ${CLUSTER_ADDRESS}/mgmt-repo/charts
$ helm install --name metering mgmt-charts/metering --namespace kube-system --set license=accept --tls
```

To uninstall/delete the metering deployment:

```console
$ helm delete metering --purge --tls
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Configuration

The following tables lists the configurable parameters of the metering service chart and their default values.

Parameter | Description | Default
--------- | ----------- | -------
`proxyIP` | The ip address of the cluster proxy | 127.0.0.1 
`mongo.host` | Service name of the MongoDB service | mongodb 
`mongo.port` | Service port of the MongoDB service |  27017
`mongo.username.secret` | Name of the secret containing the MongoDB user name | icp-mongodb-admin
`mongo.username.key`    | Key within the username secret |  user
`mongo.password.secret` | Name of the secret containing the MongoDB password | icp-mongodb-admin
`mongo.password.key`    | Key within the password secret | password
`mongo.clustercertsecret` |  Name of the secret containing the CA cert of the MongoDB service | cluster-ca-cert
`mongo.clientcertsecret` |  Name of the secret containing the client cert of the MongoDB service | cluster-ca-cert
`dm.image.repository` | Name of the image including the repository prefix (if required) of the data manager component | ibmcom/metering-data-manager
`dm.image.tag` | Docker image tag of the data manager component | latest
`dm.image.pullPolicy` | Image pull policy of the data manager component | IfNotPresent
`dm.resources.requests.cpu` | Minimum amount of CPU required | 250m.
`dm.resources.requests.memory` | Minimum amount of memory required | 2048mi
`ui.image.repository` | Name of the image including the repository prefix (if required) of the console component | ibmcom/metering-ui
`ui.image.tag` | Docker image tag of the console component | latest
`ui.image.pullPolicy` | Image pull policy of the console component | IfNotPresent
`ui.resources.requests.cpu` | Minimum amount of CPU required | 250m.
`ui.resources.requests.memory` | Minimum amount of memory required | 512mi
`reader.image.repository` | Name of the image including the repository prefix (if required) of the reader component | ibmcom/metering-data-manager
`reader.image.tag` | Docker image tag of the reader component | latest
`reader.image.pullPolicy` | Image pull policy of the reader component | IfNotPresent
`reader.resources.requests.cpu` | Minimum amount of CPU required | 250m.
`reader.resources.requests.memory` | Minimum amount of memory required | 512mi

## Limitations

There can only be a single deployment of the metering service in a cluster, it must be named metering, and it must be installed into the kube-system namespace.
