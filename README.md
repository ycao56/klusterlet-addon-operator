# endpoint component operator

A HELM operator built with [operator-sdk](https://github.com/operator-framework/operator-sdk) used to deploy management components on remote clusters

## Prerequisites

<!-- Bring this back if we bring back multiarch builds
- Must have [Go v1.12.x](https://golang.org/) installed. _NOTE: v1.13.x will NOT work_

> If you already have 1.13.x install and do not want to overwrite it here is a useful script that will allow you to have both installed simultaneously

```shell
> curl -O https://dl.google.com/go/go1.12.17.darwin-amd64.tar.gz
# may have to add a sudo before the mv
> tar xzf go1.12.17.darwin-amd64.tar.gz && mv go /usr/local/go-1.12.17
> export PATH=/usr/local/go-1.12.17/bin:$PATH
> export GOROOT=/usr/local/go-1.12.17
> go version
go version go1.12.17 darwin/amd64
```
-->

- Must have [operator-sdk](https://github.com/operator-framework/operator-sdk) v0.16.0 installed

```shell
# can be installed with the following command
> make deps
```

## Running Endpoint Component Operator for development

1. Link the `endpoint-component-operator/helm-charts` directory to `/opt/helm/helm-charts`

```shell
sudo make utils:link:setup
```

1. Install CRDs required by the operator

```shell
make utils:crds:install
```

1. Set helm-chart Version

```shell
make utils:charts:version version=1.0.0
```

1. Run Endpoint Component Operator on your laptop

```shell
make operator:run
```

## Using Endpoint Component Operator to deploy the components

To manually create a instance of the component you will need to create the component CR the spec of the CR will be use as the value override for the helm chart associated with the .the `deploy/crd` folder contain example CR for the components

The [endpoint-operator](https://github.com/open-cluster-management/endpoint-operator) project automaically create and manage the update of the CR for the components in the endpoint component operator. See Endpoint Operator's README for how to run the Endpoint Operator

## Build and publish a personal build to scratch artifactory

- `make init`
- `make operator:build`
- `make docker:tag`
- `make docker:push`

## Run functional test

The implemented funcitonal tests deploy the endpoint-component-operator in KinD v0.7.0.

The kind configuration file are located in the [build/kind-config](build/kind-config).

The test runs for each provided kind configuration.

To add new configuration, copy one of the existing config and change the `nodes.imagee` to a given image release. Check [here](https://github.com/kubernetes-sigs/kind/releases) for available kube version.

To run the test call depending on the kube version the test must run on:

- `make component/test/functional`

## Add a component into the test

To add a new component into the test, the endpoint-operator CRD must be added in the [deploy/crds](deploy/crds) directory and a corresponding CR must be added in the [deploy/crs](deploy/crd) directory.
