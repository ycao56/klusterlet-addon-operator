Adding Release Notes file at version 3.4.0

Go forward, changes to this chart MUST be summarized here for each release.

# What's new
* [ENHANCEMENT] Added more restrictions to Security Context

# Fixes

# Prerequisites
* Storage Class must be created to provision a Persistent Volume

# Version History
| Chart | Date | ICP Required | Image(s) Supported | Breaking Changes | Details |
| ----- | ---- | ------------ | ------------------ | ---------------- | ------- |
| 3.4.0 | Nov 2019 | >= 3.2.1 | | | Improved Security Context
| 3.2.1 | Aug 2019 | >= 3.2.1 | | | Updated MongoDB to 4.0.12
| 3.2.0 | May 2019 | >= 3.2 | | | Added Exporter pod for Prometheus
| 3.1.2 | Feb 2019 | >= 3.1.2 | | | Change to on-start script
| 3.1.1 | Nov 2018 | >= 3.1.1 | | | Small changes to start up scripts
| 3.0.0 | Sep 2018 | >= 3.1 | | | Security Context added, mongod runs in non-root pod

# Breaking Changes
None

# Documentation
Look at the README.md
