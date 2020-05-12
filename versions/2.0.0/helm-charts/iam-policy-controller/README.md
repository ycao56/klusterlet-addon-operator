# IAM Policy Controller

## Introduction

The `iam-policy-controller` helm chart deploys the iam policy controller which watches cluster administrator role and IAM role binding created and used within ICP/MCM

## Chart Details
The `iam-policy-controller` helm chart is deployed onto managed clusters to validate your IAM compliance policies.

## How to use IAM Policy Controller
See the product documentation for more details on IAM Policy Controller.

## Prerequisites

* Kubernetes 1.11.0 or later
* Required user type or access level: Cluster administrator

## Online user documentation

See the product documentation for more details on IAM Policy Controller.

## PodSecurityPolicy Requirements

This chart requires a PodSecurityPolicy to be bound to the `kube-system` prior to installation.

The predefined PodSecurityPolicy name, [`ibm-privileged-psp`](https://ibm.biz/cpkspec-psp) or [`privileged`](https://ibm.biz/cpkspec-scc), has been verified for this chart. If your target namespace is bound to this PodSecurityPolicy, you can proceed to install the chart. The actual psp that has been tested with is,

Custom PodSecurityPolicy definition:

```
apiVersion: extensions/v1beta1
kind: PodSecurityPolicy
metadata:
  annotations:
    kubernetes.io/description: "This policy grants access to all privileged
      host features and allows a pod to run with any
      UID and GID and any volume.
      WARNING:  This policy is the least restrictive and
      should only used for cluster administration.
      Use with caution."
    seccomp.security.alpha.kubernetes.io/allowedProfileNames: '*'
  name: ibm-privileged-psp
spec:
  allowPrivilegeEscalation: true
  allowedCapabilities:
    - '*'
  allowedUnsafeSysctls:
    - '*'
  fsGroup:
    rule: RunAsAny
  hostIPC: true
  hostNetwork: true
  hostPID: true
  hostPorts:
    - max: 65535
      min: 0
  privileged: true
  runAsUser:
    rule: RunAsAny
  seLinux:
    rule: RunAsAny
  supplementalGroups:
    rule: RunAsAny
  volumes:
    - '*'
```

## Resources Required

For more information about system requirements, see [System requirements](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.2.1/supported_system_config/system_reqs.html).

## Installing the Chart

To install the chart with the release name `iam-policy-controller`:

```bash
$ helm install --name iam-policy-controller --namespace kube-system -f values.yaml iam-policy-controller --tls
```

> **Tip**: List all releases using `helm list --tls`

## Uninstalling the Chart

To uninstall/delete the `iam-policy-controller` release:

```bash
$ helm delete iam-policy-controller --tls
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Configuration

## Limitations

There can only be a single deployment of the iam-policy-controller in a cluster, and it must be installed into the kube-system namespace.

## Red Hat OpenShift SecurityContextConstraints Requirements

The actual scc that has been tested with is,
Custom SecurityContextConstraints definition:
```
allowHostDirVolumePlugin: true
allowHostIPC: true
allowHostNetwork: true
allowHostPID: true
allowHostPorts: true
allowPrivilegeEscalation: true
allowPrivilegedContainer: true
allowedCapabilities:
- '*'
allowedUnsafeSysctls:
- '*'
apiVersion: security.openshift.io/v1
defaultAddCapabilities: null
fsGroup:
  type: RunAsAny
groups:
- system:cluster-admins
- system:nodes
- system:masters
kind: SecurityContextConstraints
metadata:
  annotations:
    kubernetes.io/description: 'privileged allows access to all privileged and host
      features and the ability to run as any user, any group, any fsGroup, and with
      any SELinux context.  WARNING: this is the most relaxed SCC and should be used
      only for cluster administration. Grant with caution.'
  name: privileged
priority: null
readOnlyRootFilesystem: false
requiredDropCapabilities: null
runAsUser:
  type: RunAsAny
seLinuxContext:
  type: RunAsAny
seccompProfiles:
- '*'
supplementalGroups:
  type: RunAsAny
users:
- system:admin
- system:serviceaccount:openshift-infra:build-controller
- system:serviceaccount:openshift-node:sync
- system:serviceaccount:openshift-sdn:sdn
- system:serviceaccount:management-infra:management-admin
- system:serviceaccount:management-infra:inspector-admin
volumes:
- '*'
```

## Copyright and trademark information

© Copyright IBM Corporation 2019

U.S. Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.

IBM®, the IBM logo and ibm.com® are trademarks of International Business Machines Corp., registered in many jurisdictions worldwide. Other product and service names might be trademarks of IBM or other companies. A current list of IBM trademarks is available on the Web at "Copyright and trademark information" at www.ibm.com/legal/copytrade.shtml.
