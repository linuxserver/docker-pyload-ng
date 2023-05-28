# syntax=docker/dockerfile:1

FROM ghcr.io/linuxserver/baseimage-alpine:3.18

# set version label
ARG BUILD_DATE
ARG VERSION
ARG PYLOAD_VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="aptalca"

ENV HOME="/config"

RUN \
  echo "**** install build packages ****" && \
  apk add --no-cache --virtual=build-dependencies \
    build-base \
    cargo \
    curl-dev \
    libffi-dev \
    libjpeg-turbo-dev \
    openssl-dev \
    python3-dev \
    zlib-dev && \
  echo "**** install packages ****" && \
  apk add --no-cache \
    ffmpeg \
    libjpeg-turbo \
    p7zip \
    python3 \
    sqlite \
    tesseract-ocr && \
  echo "**** install pyload ****" && \
  if [ -z ${PYLOAD_VERSION+x} ]; then \
    PYLOAD_VERSION=$(curl -sL  https://pypi.python.org/pypi/pyload-ng/json |jq -r '. | .info.version'); \
  fi && \
  python3 -m venv /lsiopy && \
  pip install -U --no-cache-dir \
    pip \
    wheel && \
  pip install -U --no-cache-dir --find-links https://wheel-index.linuxserver.io/alpine-3.18/ \
    pyload-ng[all]=="${PYLOAD_VERSION}" && \
  echo "**** cleanup ****" && \
  apk del --purge \
    build-dependencies && \
  rm -rf \
    /tmp/* \
    ${HOME}/.cache \
    ${HOME}/.cargo

# add local files
COPY root/ /

# ports and volumes
EXPOSE 8000
VOLUME /config
