#!/bin/bash

set -e

# Create link to pre-commit hook
if [[ ! -e .git/hooks/pre-commit ]]; then
    ln -sf ../../build/git-hooks/pre-commit .git/hooks/pre-commit
fi

set -x

if [[ ! -e .build-harness ]]; then
    curl -vfo .build-harness -H "Authorization: token ${GITHUB_TOKEN}" -H "Accept: application/vnd.github.v3.raw" "https://raw.github.ibm.com/ICP-DevOps/build-harness/master/templates/Makefile.build-harness"
fi

# +curl -vfo .build-harness -H 'Authorization: token [secure]' -H 'Accept: application/vnd.github.v3.raw' https://raw.github.ibm.com/ICP-DevOps/build-harness/master/templates/Makefile.build-harness
#   % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
#                                  Dload  Upload   Total   Spent    Left  Speed
#   0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0*   Trying 169.60.70.162...
# * Connected to raw.github.ibm.com (169.60.70.162) port 443 (#0)
# * found 148 certificates in /etc/ssl/certs/ca-certificates.crt
# * found 594 certificates in /etc/ssl/certs
# * ALPN, offering http/1.1
# * SSL connection using TLS1.2 / ECDHE_RSA_AES_128_GCM_SHA256
# * 	 server certificate verification OK
# * 	 server certificate status verification SKIPPED
# * 	 common name: *.github.ibm.com (matched)
# * 	 server certificate expiration date OK
# * 	 server certificate activation date OK
# * 	 certificate public key: RSA
# * 	 certificate version: #3
# * 	 subject: C=US,ST=New York,L=Armonk,O=International Business Machines Corporation,CN=*.github.ibm.com
# * 	 start date: Mon, 25 Jun 2018 00:00:00 GMT
# * 	 expire date: Fri, 11 Sep 2020 12:00:00 GMT
# * 	 issuer: C=US,O=DigiCert Inc,CN=DigiCert SHA2 Secure Server CA
# * 	 compression: NULL
# * ALPN, server accepted to use http/1.1
# > GET /ICP-DevOps/build-harness/master/templates/Makefile.build-harness HTTP/1.1
# > Host: raw.github.ibm.com
# > User-Agent: curl/7.47.0
# > Authorization: token [secure]
# > Accept: application/vnd.github.v3.raw
# >
# * The requested URL returned error: 404 Not Found
#   0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
# * Closing connection 0
# curl: (22) The requested URL returned error: 404 Not Found
