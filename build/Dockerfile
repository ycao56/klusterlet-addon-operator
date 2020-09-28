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

ARG VCS_REF
ARG VCS_URL
ARG IMAGE_NAME
ARG IMAGE_DESCRIPTION
ARG IMAGE_VERSION

# upstream labels
LABEL org.label-schema.vendor="Red Hat" \
      org.label-schema.name="$IMAGE_NAME" \
      org.label-schema.description="$IMAGE_DESCRIPTION" \
      org.label-schema.vcs-ref="$VCS_REF" \
      org.label-schema.vcs-url="$VCS_URL" \
      org.label-schema.license="Red Hat Advanced Cluster Management for Kubernetes EULA" \
      org.label-schema.schema-version="1.0" \
      vendor="Red Hat" \
      name="$IMAGE_NAME" \
      summary="$IMAGE_DESCRIPTION" \
      description="$IMAGE_DESCRIPTION" \
      version="$IMAGE_VERSION" \
      release="$VCS_REF" 
