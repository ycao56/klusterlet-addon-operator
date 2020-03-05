# What's new in 1.7.0
* [FEATURE] Multiple Prometheus instances support in hub cluster of MCM
* [FEATURE] Generate ServiceMonitor of managed clusters for prometheus federation


# Fixes

# Prerequisites
1. IBM Cloud Private 2.1.0.3 or higher for managed mode deployment.
2. PV provisioner support in the underlying infrastructure if need persistent volume to store data


# Version History
| Chart | Date | ICP Required | Image(s) Supported | Breaking Changes | Details |
| ----- | ---- | ------------ | ------------------ | ---------------- | ------- |
| 1.7.0 | Nov 2019 | >= 3.2.1 | | | Multiple Prometheus instances support in hub cluster of MCM
| 1.6.0 | Aug 2019 | >= 3.2.1 | | | Prometheus Operator included
| 1.5.0 | May 2019 | >= 3.2 | | | Grafana multi-tenant support
| 1.4.0 | Feb 2019 | >= 3.1.2 | | | CRDs for grafana dashboards and alert rules, s390x support
| 1.3.0 | Nov 2018 | >= 3.1.1 | | | out-of-box grafana dashboards/alert rules, containers run using non-root user
| 1.2.0 | Sep 2018 | >= 3.1 | | | components upgrade; rbac support; OpenShift support
| 1.1.1 | Jun 2018 | >= 2.1.0.3 | | | chart test stuff and probes
| 1.1.0 | May 2018 | >= 2.1.0.3 | | | support managed mode
