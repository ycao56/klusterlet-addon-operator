# cis-controller-chart
CIS Policy Controller Chart

## Overview

Center for Internet Security (CIS) has become the de facto industry standard for security compliance. The CIS organization publishes security benchmarks for Operating Systems, Databases, Middleware, Kubernetes, Docker etc. These benchmarks provide best practices and recommendations to safeguard the Operating Systems, Software, Networks that are vulnerable to attacks. The CIS benchmarks for Kubernetes and Docker provide recommendations for safeguarding Kubernetes and Docker from attacks. There are tools available for checking systems for CIS compliance. This chart installs tooling to gather the results of CIS compliance checks, and provides a dashboard view of its CIS compliance on the MCM hub.

## System Context
The CIS Controller leverages the GRC Policy Framework by extending the policy for CIS controls. A new kubernetes CRD will be created that will define CisPolicy resource. 

The benchmark tool used to check for K8s CIS compliance is kube-bench from aquasecurity. The benchmark tool used to check for docker runtime CIS compliance is docker-bench-security. The CIS Controller makes use of a frame capturing technique that allows the tool to run on one node and safely gather the results from all the nodes in the cluster. The controller includes crawlers that check for any new pods or changes to pods which then triggers the benchmark tools to run the checks.

The CIS Controller can be deployed to ICP, OpenShift, Azure or another managed cluster.

## Configuration

`cloud_env`: Specifies the type of cluster to be monitored

`persistence`: Set to true to use persistent volume created by IBM Cloud Private Installer. When false, Minio data is not persisted.
