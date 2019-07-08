# What's new in 0.7.0
* Support custom certificate expiration duration and renewal windows.
* Support for the ACME HTTP issuer.
* Certificate expiration dates can be easily viewed.
* Cert-Manager can restart pods when certificates are renewed.
* Support for IP Addresses as alternate names.

# Prerequisites
* Kubernetes Version 1.11 or later

# Known issues
* The cert-manager apiserver Webhook is not enabled and cannot be used on ICP.
* ACME DNS Issuers are not supported.

# Fixes
* ECDSA Certificates no longer have to be signed by an ECDSA CA.

# Version History
| Chart | Date           | Details                           |
| ----- | -------------- | --------------------------------- |
| 0.3.2 | September 2018 | First full release                |
| 0.5.0 | November 2018  | Full release upgrade              |
| 0.5.0.1 | February 2019  | Image refresh                   |
| 0.7.0 | May 2019  | Full release upgrade                   |
