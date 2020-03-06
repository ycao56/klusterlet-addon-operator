# Certificate Policy Controller

## Introduction
This chart deploys the Certificate Policy Controller that can be used to watch the expiration of certificates used within OpenShift. You can use this controller to ensure that your certificates don't expire within a given amount of time and that your cluster(s) is compliant.

## Chart Details
The certificate policy controller is deployed to managed clusters so expiring
certificates can be identified across the management domain.

## How to use Certificate Policy Controller
See the product documentation for more details on Certificate Policy Controller.

## Prerequisites
1. Kubernetes version 1.11.0 or higher
2. Helm version 2.7.0 or higher
3. Cluster running Kubernetes

## Resources Required
Docker images:

| Image                        | Version |
| ---------------------------- | ------- |
| cert-policy-controller       | 3.3.1   |

CPU & Memory:
| Resource | Limits| Required |
|----------|--------|---------|
| CPU      |  100m  | 200m  |
| Memory   |  150Mi | 300MiB |

## Limitations
* The controller only looks at Kubernetes Secrets for certificates.

### PodSecurityPolicy Requirements
The predefined `PodSecurityPolicy` name: [`ibm-privileged-psp`](https://ibm.biz/cpkspec-psp) has been verified for this chart, if your target namespace is bound to this `PodSecurityPolicy` you can proceed to install the chart.

This chart also defines a custom `PodSecurityPolicy` which can be used to finely control the permissions/capabilities needed to deploy this chart. You can enable this custom `PodSecurityPolicy` using the management console. Note that this `PodSecurityPolicy` is already defined when common services is installed.

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
      name: custom-restricted-psp
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

### Red Hat OpenShift SecurityContextConstraints Requirements
This chart requires a SecurityContextConstraints to be bound to the target namespace prior to installation. To meet this requirement there may be cluster scoped as well as namespace scoped pre and post actions that need to occur.

The predefined SecurityContextConstraints name: [`ibm-privileged-scc`](https://ibm.biz/cpkspec-scc) has been verified for this chart, if your target namespace is bound to this SecurityContextConstraints resource you can proceed to install the chart.

This chart also defines a custom SecurityContextConstraints which can be used to finely control the permissions/capabilities needed to deploy this chart. You can enable this custom SecurityContextConstraints resource using the supplied instructions/scripts in the pak_extension pre-install directory.

- From the user interface, you can copy and paste the following snippets to enable the custom SecurityContextConstraints
  - Custom SecurityContextConstraints definition:
    ```
    apiVersion: security.openshift.io/v1
    kind: SecurityContextConstraints
    metadata:
      name: ibm-chart-dev-scc
    readOnlyRootFilesystem: false
    allowedCapabilities:
    - CHOWN
    - DAC_OVERRIDE
    - SETGID
    - SETUID
    - NET_BIND_SERVICE
    seLinux:
      type: RunAsAny
    supplementalGroups:
      type: RunAsAny
    runAsUser:
      type: RunAsAny
    fsGroup:
      rule: RunAsAny
    volumes:
    - configMap
    - secret
    ```

## Installing the Chart
The certificate expiration policy controller service can be installed either by the command line or through the Management Console.

To install on the command line, you must have your certificate manager chart ready and the images required by the chart.
1. `helm install <cert-policy-controller chart> -n cert-policy-controller --namespace kube-system --tls`

## Configurations
Configurations for installing the certificate expiration policy controller service can be found in the `values.yaml` file.

These values may be overridden by specifying a `values-override.yaml` file and installing or upgrading cert-policy-controller like so:
`helm install <cert-policy-controller chart> -f values-override.yaml -n cert-policy-controller --namespace kube-system --tls`

