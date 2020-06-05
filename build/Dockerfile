FROM openshift/origin-release:golang-1.13 as builder
ARG REMOTE_SOURCE
ARG REMOTE_SOURCE_DIR
ARG COMPONENT_VERSION

ENV USE_VENDORIZED_BUILD_HARNESS=true
ENV COMPONENT_NAME=klusterlet-component-operator
ENV COMPONENT_VERSION="${COMPONENT_VERSION}"
ENV COMPONENT_TAG_EXTENSION=" "

COPY $REMOTE_SOURCE $REMOTE_SOURCE_DIR/app

WORKDIR $REMOTE_SOURCE_DIR/app

ENV GO111MODULE=on 

RUN GOFLAGS="" bash ./build/build-helm-operator-bin.sh

FROM registry.access.redhat.com/ubi8/ubi-minimal:latest
RUN microdnf update

ARG REMOTE_SOURCE
ARG REMOTE_SOURCE_DIR

ENV OPERATOR=/usr/local/bin/helm-operator \
    USER_UID=1001 \
    USER_NAME=helm \
    HOME=/opt/helm

# install operator
COPY --from=builder $REMOTE_SOURCE_DIR/app/build/bin/helm-operator /usr/local/bin/helm-operator
COPY --from=builder $REMOTE_SOURCE_DIR/app/build/bin/entrypoint /usr/local/bin/entrypoint
COPY --from=builder $REMOTE_SOURCE_DIR/app/build/bin/user_setup /usr/local/bin/user_setup

# install charts
COPY --from=builder $REMOTE_SOURCE_DIR/app/versions/ ${HOME}/versions

RUN /usr/local/bin/user_setup

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
