# Copyright Contributors to the Open Cluster Management project

FROM quay.io/operator-framework/helm-operator:v0.19.4

USER root
RUN microdnf update -y

ARG REMOTE_SOURCE

ENV OPERATOR=/usr/local/bin/helm-operator \
    USER_UID=1001 \
    USER_NAME=helm \
    HOME=/opt/helm

# install operator
COPY $REMOTE_SOURCE/build/bin/entrypoint /usr/local/bin/entrypoint

# install charts
COPY $REMOTE_SOURCE/helm-charts/ ${HOME}/helm-charts

ENTRYPOINT ["/usr/local/bin/entrypoint"]

USER ${USER_UID}
