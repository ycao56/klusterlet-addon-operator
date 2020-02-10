# IBM Cloud Private Certificate Policy Controller

## Introduction
This chart deploys the IBM Cloud Private Certificate Policy Controller that can be used to watch the expiration of certificates used within IBM Cloud Private. You can use this controller to ensure that your certificates don't expire within a given amount of time and that your cluster(s) is compliant.

## Chart Details
One instance of the certificate policy controller is deployed when IBM Cloud Private and Multi-cloud Manager are installed.

## How to use IBM Cloud Private Certificate Policy Controller
See the IBM Cloud Private product documentation in the [IBM Knowledge Center](https://www.ibm.com/support/knowledgecenter/) for more details on IBM Cloud Private Certificate Policy Controller.

## Limitations
* The controller only looks at Kubernetes Secrets for certificates.
