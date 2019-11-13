FROM quay.io/operator-framework/helm-operator:v0.9.0

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

LABEL release="$VCS_REF" \
      vendor="$IMAGE_VENDOR" \
      name="$IMAGE_NAME" \
      summary="$IMAGE_SUMMARY" \
      description="$IMAGE_DESCRIPTION" \
      version="$IMAGE_VERSION"  \
      maintainer="$IMAGE_MAINTAINER"  \
      vcs_url="$VCS_URL" \
      image_name_arch="$IMAGE_NAME_ARCH"  \
      openshifttags="$IMAGE_OPENSHIFT_TAGS"