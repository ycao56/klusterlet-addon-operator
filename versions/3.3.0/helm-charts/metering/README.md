# metering
* [Metering](https://www.ibm.com/cloud/cloud-pak-for-management) is used to collect, view, and download detailed usage metrics for your applications and cluster.

## Introduction
This chart deploys the metering service that can be used to collect, view, and download detailed usage metrics for your applications and cluster.  Fine grained measurements are visible through the metering console and the data is kept for up to three months. Monthly summary reports are also available for you to download and are kept for up to 24 months.  Additionally, the aggregated measurements collected by this chart can be rolled up and viewed in aggregate in the IBM Multicloud Manager.

## Chart Details
This chart includes
  - Deployments of the metering data manager and user interface services;
  - Daemonset of the metering reader service;
  - Ingress configurations for the metering services;

## Prerequisites
* OpenShift Container Platform 3.11
* mongodb
* 1 cpu and 896Mi of memory
* Cluster Admin role for installation 

### PodSecurityPolicy Requirements
The predefined PodSecurityPolicy name: [`ibm-restricted-psp`](https://ibm.biz/cpkspec-psp) has been verified for this chart, if your target namespace is bound to this PodSecurityPolicy you can proceed to install the chart.  The ibm-restricted-psp is shown below:

```
apiVersion: extensions/v1beta1
kind: PodSecurityPolicy
metadata:
  annotations:
    kubectl.kubernetes.io/last-applied-configuration: |
      {"apiVersion":"extensions/v1beta1","kind":"PodSecurityPolicy","metadata":{"annotations":{"kubernetes.io/description":"This policy is the most restrictive, requiring pods to run with a non-root UID, and preventing pods from accessing the host.","seccomp.security.alpha.kubernetes.io/allowedProfileNames":"docker/default","seccomp.security.alpha.kubernetes.io/defaultProfileName":"docker/default"},"name":"ibm-restricted-psp"},"spec":{"allowPrivilegeEscalation":false,"forbiddenSysctls":["*"],"fsGroup":{"ranges":[{"max":65535,"min":1}],"rule":"MustRunAs"},"hostIPC":false,"requiredDropCapabilities":["ALL"],"runAsUser":{"rule":"MustRunAsNonRoot"},"seLinux":{"rule":"RunAsAny"},"supplementalGroups":{"ranges":[{"max":65535,"min":1}],"rule":"MustRunAs"},"volumes":["configMap","emptyDir","projected","secret","downwardAPI","persistentVolumeClaim"]}}
    kubernetes.io/description: This policy is the most restrictive, requiring pods
      to run with a non-root UID, and preventing pods from accessing the host.
    seccomp.security.alpha.kubernetes.io/allowedProfileNames: docker/default
    seccomp.security.alpha.kubernetes.io/defaultProfileName: docker/default
  creationTimestamp: "2019-09-23T12:13:43Z"
  name: ibm-restricted-psp
  resourceVersion: "336"
  selfLink: /apis/extensions/v1beta1/podsecuritypolicies/ibm-restricted-psp
  uid: 95c28520-ddfb-11e9-ac59-005056a04f73
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


### Red Hat OpenShift SecurityContextConstraints Requirements
The predefined SecurityContextConstraints name: [`ibm-restricted-scc`](https://ibm.biz/cpkspec-scc) has been verified for this chart, if your target namespace is bound to this SecurityContextConstraints resource you can proceed to install the chart. The ibm-restricted-scc is shown below:

```
allowHostDirVolumePlugin: false
allowHostIPC: false
allowHostNetwork: false
allowHostPID: false
allowHostPorts: false
allowPrivilegeEscalation: false
allowPrivilegedContainer: false
allowedCapabilities: null
apiVersion: security.openshift.io/v1
defaultAddCapabilities: null
defaultAllowPrivilegeEscalation: false
forbiddenSysctls:
- '*'
fsGroup:
  ranges:
  - max: 65535
    min: 1
  type: MustRunAs
groups: []
kind: SecurityContextConstraints
metadata:
  annotations:
    cloudpak.ibm.com/version: 1.1.0
    kubernetes.io/description: This policy is the most restrictive, requiring pods
      to run with a non-root UID, and preventing pods from accessing the host. The
      UID and GID will be bound by ranges specified at the Namespace level.
  creationTimestamp: "2019-10-30T17:52:00Z"
  generation: 1
  name: ibm-restricted-scc
  resourceVersion: "16218"
  selfLink: /apis/security.openshift.io/v1/securitycontextconstraints/ibm-restricted-scc
  uid: f97bc313-fb3d-11e9-b6a1-1696a92f80af
priority: null
readOnlyRootFilesystem: false
requiredDropCapabilities:
- ALL
runAsUser:
  type: MustRunAsNonRoot
seLinuxContext:
  type: RunAsAny
seccompProfiles:
- docker/default
supplementalGroups:
  ranges:
  - max: 65535
    min: 1
  type: MustRunAs
users: []
volumes:
- configMap
- downwardAPI
- emptyDir
- persistentVolumeClaim
- projected
- secret
Steves-MBP:aws-ipi sgrube@us.ibm.com$ oc get scc ibm-restricted-scc -o yaml
allowHostDirVolumePlugin: false
allowHostIPC: false
allowHostNetwork: false
allowHostPID: false
allowHostPorts: false
allowPrivilegeEscalation: false
allowPrivilegedContainer: false
allowedCapabilities: null
apiVersion: security.openshift.io/v1
defaultAddCapabilities: null
defaultAllowPrivilegeEscalation: false
forbiddenSysctls:
- '*'
fsGroup:
  ranges:
  - max: 65535
    min: 1
  type: MustRunAs
groups: []
kind: SecurityContextConstraints
metadata:
  annotations:
    cloudpak.ibm.com/version: 1.1.0
    kubernetes.io/description: This policy is the most restrictive, requiring pods
      to run with a non-root UID, and preventing pods from accessing the host. The
      UID and GID will be bound by ranges specified at the Namespace level.
  creationTimestamp: "2019-10-30T17:52:00Z"
  generation: 1
  name: ibm-restricted-scc
  resourceVersion: "16218"
  selfLink: /apis/security.openshift.io/v1/securitycontextconstraints/ibm-restricted-scc
  uid: f97bc313-fb3d-11e9-b6a1-1696a92f80af
priority: null
readOnlyRootFilesystem: false
requiredDropCapabilities:
- ALL
runAsUser:
  type: MustRunAsNonRoot
seLinuxContext:
  type: RunAsAny
seccompProfiles:
- docker/default
supplementalGroups:
  ranges:
  - max: 65535
    min: 1
  type: MustRunAs
users: []
volumes:
- configMap
- downwardAPI
- emptyDir
- persistentVolumeClaim
- projected
- secret
```

## Resources Required
* 1 cpu and 896Mi of memory

## Installing the Chart
To install the chart with the release name `metering`:

```bash
$ helm install --tls --namespace <your pre-created namespace> --name metering stable/metering
```

The command deploys <Chart name> on the Kubernetes cluster in the default configuration. The [configuration](#configuration) section lists the parameters that can be configured during installation.


> **Tip**: List all releases using `helm list`

### Verifying the Chart
See the instruction (from NOTES.txt within chart) after the helm installation completes for chart verification. The instruction can also be viewed by running the command: helm status my-release --tls.

### Uninstalling the Chart

To uninstall/delete the `metering` deployment:

```bash
$ helm delete my-release --purge --tls
```
The command removes all the Kubernetes components associated with the chart and deletes the release.

## Configuration
* Define all the parms in the values.yaml 
* Include "how used" information
* If special configuration impacts a "set of values", call out the set of values required (a = true, y = abc_value, c = 1) to get a desired outcome. One example may be setting on multiple values to turn on or off TLS. 

The following tables lists the configurable parameters of the metering chart and their default values.

|Parameter | Description | Default |
|--------- | ----------- | ------- |
|`external.cluster_ip` | The external ip address of the cluster | 127.0.0.1 | 
|`external.cluster_port` | The external port of the cluster | 8443 | 
|`external.cluster_name` | The name of the cluster | mycluster | 
|`mongo.host` | Service name of the MongoDB service | mongodb | 
|`mongo.port` | Service port of the MongoDB service |  27017 |
|`mongo.username.secret` | Name of the secret containing the MongoDB user name | icp-mongodb-admin |
|`mongo.username.key`    | Key within the username secret |  user |
|`mongo.password.secret` | Name of the secret containing the MongoDB password | icp-mongodb-admin |
|`mongo.password.key`    | Key within the password secret | password |
|`mongo.clustercertsecret` |  Name of the secret containing the CA cert of the MongoDB service | cluster-ca-cert |
|`mongo.clientcertsecret` |  Name of the secret containing the client cert of the MongoDB service | icp-mongodb-client-cert |
|`dm.image.repository` | Name of the image including the repository prefix (if required) of the data manager component | ibmcom/metering-data-manager |
|`dm.image.tag` | Docker image tag of the data manager component | latest |
|`dm.image.pullPolicy` | Image pull policy of the data manager component | IfNotPresent |
|`dm.resources.requests.cpu` | Minimum amount of CPU required | 250m |
|`dm.resources.requests.memory` | Minimum amount of memory required | 512mi |
|`dm.resources.limits.cpu` | Maximum amount of CPU allowed | 1000m |
|`dm.resources.limits.memory` | Maximum amount of memory allowed | 2560mi |
|`ui.image.repository` | Name of the image including the repository prefix (if required) of the console component | ibmcom/metering-ui |
|`ui.image.tag` | Docker image tag of the console component | latest |
|`ui.image.pullPolicy` | Image pull policy of the console component | IfNotPresent |
|`ui.resources.requests.cpu` | Minimum amount of CPU required | 250m |
|`ui.resources.requests.memory` | Minimum amount of memory required | 128mi |
|`ui.resources.limits.cpu` | Maximum amount of CPU allowed | 500m |
|`ui.resources.limits.memory` | Maximum amount of memory allowed | 512mi |
|`mcmui.image.repository` | Name of the image including the repository prefix (if required) of the multicloud metering console component | ibmcom/metering-mcmui |
|`mcmui.image.tag` | Docker image tag of the multicloud metering console component | latest |
|`mcmui.image.pullPolicy` | Image pull policy of the multicloud metering console component | IfNotPresent |
|`mcmui.resources.requests.cpu` | Minimum amount of CPU required | 250m |
|`mcmui.resources.requests.memory` | Minimum amount of memory required | 128mi |
|`mcmui.resources.limits.cpu` | Maximum amount of CPU allowed | 500m |
|`mcmui.resources.limits.memory` | Maximum amount of memory allowed | 256mi |
|`reader.image.repository` | Name of the image including the repository prefix (if required) of the reader component | ibmcom/metering-data-manager |
|`reader.image.tag` | Docker image tag of the reader component | latest |
|`reader.image.pullPolicy` | Image pull policy of the reader component | IfNotPresent |
|`reader.resources.requests.cpu` | Minimum amount of CPU required | 250m |
|`reader.resources.requests.memory` | Minimum amount of memory required | 128mi |
|`reader.resources.limits.cpu` | Maximum amount of CPU allowed | 500m |
|`reader.resources.limits.memory` | Maximum amount of memory allowed | 512mi |

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`.

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. For example,

> **Tip**: You can use the default values.yaml

## Storage
* All data is stored in mongodb

## Limitations
* There can only be a single deployment of the metering service in a cluster.

## Documentation
For more information go to [Multicloud Manager Enterprise Knowledge Center](https://www.ibm.com/support/knowledgecenter/en/SSBS6K_3.2.1/manage_metrics/metering_service.html)
