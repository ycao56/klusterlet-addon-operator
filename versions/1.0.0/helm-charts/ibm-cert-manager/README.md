# IBM Cloud Private Certificate Manager

## Introduction
This chart deploys the IBM Cloud Private certificate manager service that can be used to issue and manage certificates for services running on IBM Cloud Private. You can use cert-manager to create and mount a certificate to a Kubernetes Deployment, StatefulSet, or DaemonSet. You can also create and add a certificate to a Kubernetes Ingress. It will ensure certificates are valid and up to date periodically, and it will attempt to renew certificates at an appropriate time before expiry.

## Chart Details
One instance of cert-manager is deployed to a single master node when IBM Cloud Private is installed.

## How to use IBM-Cert-Manager
See the IBM Cloud Private product documentation in the [IBM Knowledge Center](https://www.ibm.com/support/knowledgecenter/) for more details on cert-manager, IBM Cloud Private's Kubernetes certificate manager service.

## Prerequisites
1. Kubernetes version 1.9.0 or higher
2. Helm version or higher
3. Cluster running Kubernetes
4. A dedicated cert-manager namespace on the cluster

## Resources Required
Docker images:

| Image                        | Version |
| ---------------------------- | ------- |
| icp-cert-manager             | 0.10.0  |
| icp-cert-policy-controller   | 3.2.2   |

### PodSecurityPolicy Requirements
The predefined `PodSecurityPolicy` name: [`ibm-privileged-psp`](https://ibm.biz/cpkspec-psp) has been verified for this chart, if your target namespace is bound to this `PodSecurityPolicy` you can proceed to install the chart.

This chart also defines a custom `PodSecurityPolicy` which can be used to finely control the permissions/capabilities needed to deploy this chart. You can enable this custom `PodSecurityPolicy` using the IBM Cloud Private management console. Note that this `PodSecurityPolicy` is already defined in IBM Cloud Private 3.1.1 or higher.

- From the user interface, you can copy and paste the following snippets to enable the custom `PodSecurityPolicy` into the create resource section
  - Custom PodSecurityPolicy definition:
    ```yaml
    apiVersion: extensions/v1beta1
    kind: PodSecurityPolicy
    metadata:
      annotations:
        kubernetes.io/description: "This policy is the most restrictive,
          requiring pods to run with a non-root UID, and preventing pods from accessing the host."
        apparmor.security.beta.kubernetes.io/allowedProfileNames: runtime/default
        apparmor.security.beta.kubernetes.io/defaultProfileName: runtime/default
        seccomp.security.alpha.kubernetes.io/allowedProfileNames: docker/default
        seccomp.security.alpha.kubernetes.io/defaultProfileName: docker/default
      name: ibm-restricted-psp
    spec:
      allowPrivilegeEscalation: false
      forbiddenSysctls:
      - '*'
      fsGroup:
        ranges:
        - max: 65535
          min: 1
        rule: MustRunAs
      requiredDropCapabilities:
      - ALL
      runAsUser:
        rule: MustRunAsNonRoot
      seLinux:
        rule: RunAsAny
      supplementalGroups:
        ranges:
        - max: 65535
          min: 1
        rule: MustRunAs
      volumes:
      - configMap
      - emptyDir
      - projected
      - secret
      - downwardAPI
      - persistentVolumeClaim
    ```
  - Custom ClusterRole for the custom PodSecurityPolicy:
    ```
    apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRole
    metadata:
      name: ibm-restricted-psp-clusterrole
    rules:
    - apiGroups:
      - extensions
      resourceNames:
      - ibm-restricted-psp
      resources:
      - podsecuritypolicies
      verbs:
      - use
    ```
## Installing the Chart
One instance of IBM Cloud Private certificate manager service is installed for every IBM Cloud Private Management.

IBM Cloud Private certificate manager service can be installed either by the command line or through the IBM Cloud Private Management Console if one instance is not already present on the cluster.

To install on the command line, you must have your IBM Cloud Private certificate manager chart ready and the images required by the chart.
1. `helm install <cert-manager chart> -n cert-manager --namespace cert-manager --tls`

## Configurations
Configurations for installing the IBM Cloud Private certificate manager service can be found in the `values.yaml` file. 

These values may be overridden by specifying a `values-override.yaml` file and installing or upgrading cert-manager like so:
`helm install <cert-manager chart> -f values-override.yaml -n cert-manager --namespace cert-manager --tls`

## Limitations
* There can only be a single deployment of the certificate manager service in a cluster, and it is installed by default.
