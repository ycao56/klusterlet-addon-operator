# What's new in 0.10.0
* KeyUsages field for Certificates
* KeyEncoding field in Certificates to specify the private key encoding
* Deprecation of spec.acme field in Certificates
* New field spec.acme.solvers in Issuers for ACME Issuers

# Prerequisites
* Kubernetes Version 1.11 or later

# Documentation
See the documentation included with the product.

# Known issues
* ACME DNS Issuers are not supported.

# Fixes
* Refactoring to better generate serving certificates for the webhook

# Breaking Changes
* Validation for commonName, or the first dnsName if commonName is not specified, is active. The value must be less than 64 characters long.
* Validation that the secretName for each Certificate must be unique within its namespace.

# Version History
| Chart   | Date               | Details                           |
| ------- | ------------------ | --------------------------------- |
| 0.3.2   | September 2018     | First full release                |
| 0.5.0   | November 2018      | Full release upgrade              |
| 0.5.0.1 | February 2019      | Image refresh                     |
| 0.7.0   | May 2019           | Full release upgrade              |
| 0.7.1   | August 2019        | Image refresh                     |
| 0.10.0  | December 2019      | Full release upgrade              |
