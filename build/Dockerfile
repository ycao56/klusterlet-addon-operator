FROM quay.io/operator-framework/helm-operator:v0.10.1

ARG VCS_REF
ARG VCS_URL
ARG IMAGE_NAME
ARG IMAGE_VENDOR
ARG IMAGE_NAME_ARCH
ARG IMAGE_SUMMARY
ARG IMAGE_MAINTAINER
ARG IMAGE_VERSION
ARG IMAGE_RELEASE
ARG IMAGE_SUMMARY
ARG IMAGE_OPENSHIFT_TAGS
ARG IMAGE_DESCRIPTION

COPY versions/ ${HOME}/versions
COPY licenses /licenses

LABEL org.label-schema.vendor="IBM" \
      org.label-schema.name="$IMAGE_NAME_ARCH" \
      org.label-schema.description="$IMAGE_DESCRIPTION" \
      org.label-schema.vcs-ref="$VCS_REF" \
      org.label-schema.vcs-url="$VCS_URL" \
      org.label-schema.license="Licensed Materials - Property of IBM" \
      org.label-schema.schema-version="1.0" \
      name="$IMAGE_NAME" \
      vendor="IBM" \
      version="$IMAGE_VERSION" \
      release="$VCS_REF" \
      description="$IMAGE_DESCRIPTION" \
      summary="$IMAGE_SUMMARY" \
      vcs_url="$VCS_URL" 