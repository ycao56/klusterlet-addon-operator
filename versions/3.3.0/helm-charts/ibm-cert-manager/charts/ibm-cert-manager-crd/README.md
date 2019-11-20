# Certificate Manager Custom Resource Definitions

## Introduction
This chart deploys the certificate manager customer resource definitions needed by the cert-manager chart.

## Chart Details
This chart only performs preliminary configuration required for the cert-manager chart.

## How to use IBM-Cert-Manager
See the IBM Cloud Private product documentation in the [IBM Knowledge Center](https://www.ibm.com/support/knowledgecenter/) for more details on cert-manager, IBM Cloud Private's Kubernetes certificate manager service.

## Prerequisites
* There is not already a version of this chart installed.
* The following custom resources do not already exist: Certificates, Issuers, ClusterIssuers, Orders, Challenges

## Resources Required
* None

## Installing the Chart
The chart can be installed either on its own or along with the cert-manager chart. To install the chart, use the `helm` command or log into the IBM Cloud Private management console to install.

## Configurations
* None

## Limitations
* See the limitations for the cert-manager chart.
