[comment]: # ( Copyright Contributors to the Open Cluster Management project )

# klusterlet addon operator

Klusterlet addon operator supports deployment of add-ons on ManagedCluster for ACM.

## Community, discussion, contribution, and support

Check the [CONTRIBUTING Doc](CONTRIBUTING.md) for how to contribute to the repo.

------

## Getting Started

This is a guide on how to build and deploy klusterlet addon operator from code.

A HELM operator built with [operator-sdk](https://github.com/operator-framework/operator-sdk) used to deploy management components on remote clusters

## Prerequisites

- Must have [operator-sdk](https://github.com/operator-framework/operator-sdk) v0.18.1 installed

```shell
# can be installed with the following command
> make deps
```

## Running Klusterlet Addon Operator for development

1. Link the `klusterlet-addon-operator/helm-charts` directory to `/opt/helm/helm-charts`

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

1. Run Klusterlet Component Operator on your laptop

```shell
make operator:run
```

## Using Klusterlet Component Operator to deploy the components

To manually create a instance of the component you will need to create the component CR the spec of the CR will be use as the value override for the helm chart associated with the .the `deploy/crd` folder contain example CR for the components

The [klusterlet-addon-controller](https://github.com/stolostron/klusterlet-addon-controller) project automaically create and manage the update of the CR for the components in the klusterlet component operator. See Klusterlet Operator's README for how to run the Klusterlet Operator

## Build and publish a personal build to scratch artifactory

- `export GITHUB_USER=<GITHUB_USER>`
- `export GITHUB_TOKEN=<GITHUB_TOKEN>`
- `export DOCKER_USER=<Docker username>`
- `export DOCKER_PASS=<Docker password>`

- `make init`
- `make operator:build`
- `make docker:tag`
- `make docker:push`

## Run functional test

The implemented funcitonal tests deploy the klusterlet-component-operator in KinD v0.7.0.

The kind configuration file are located in the [build/kind-config](build/kind-config).

The test runs for each provided kind configuration.

To add new configuration, copy one of the existing config and change the `nodes.imagee` to a given image release. Check [here](https://github.com/kubernetes-sigs/kind/releases) for available kube version.

To run the test call depending on the kube version the test must run on:

- `make functional-test-full`      # To build the image, then create kind clusters and run the gingko tests on them.  (Ideal for someone new to the repo and wanting to test changes)
- `make component/test/functional` # To create kind clusters and run the gingko tests on them (image already built)

## Add a component into the test

To add a new component into the test, the klusterlet-operator CRD must be added in the [deploy/crds](deploy/crds) directory and a corresponding CR must be added in the [deploy/crs](deploy/crd) directory.
