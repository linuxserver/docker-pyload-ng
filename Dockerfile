# syntax=docker/dockerfile:1

FROM ghcr.io/linuxserver/unrar:latest as unrar

FROM ghcr.io/linuxserver/baseimage-alpine:3.18

# set version label
ARG BUILD_DATE
ARG VERSION
ARG PYLOAD_COMMIT
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="aptalca"

ENV HOME="/config"

RUN \
  echo "**** install build packages ****" && \
  apk add --no-cache --virtual=build-dependencies \
    build-base \
    cargo \
    curl-dev \
    git \
    libffi-dev \
    libjpeg-turbo-dev \
    openssl-dev \
    python3-dev \
    zlib-dev && \
  echo "**** install packages ****" && \
  apk add --no-cache \
    ffmpeg \
    libjpeg-turbo \
    7zip \
    python3 \
    sqlite \
    tesseract-ocr && \
  echo "**** install pyload ****" && \
  if [ -z ${PYLOAD_COMMIT+x} ]; then \
    PYLOAD_COMMIT=$(curl -sX GET "https://api.github.com/repos/pyload/pyload/branches/develop" \
      | awk '/sha/{print $4;exit}' FS='[""]'); \
  fi && \
  python3 -m venv /lsiopy && \
  pip install -U --no-cache-dir \
    pip \
    wheel && \
  pip install -U --no-cache-dir --find-links https://wheel-index.linuxserver.io/alpine-3.18/ \
    "git+https://github.com/pyload/pyload.git@${PYLOAD_COMMIT}" && \
  echo "**** cleanup ****" && \
  apk del --purge \
    build-dependencies && \
  rm -rf \
    /tmp/* \
    ${HOME}/.cache \
    ${HOME}/.cargo

# add local files
COPY root/ /

# add unrar
COPY --from=unrar /usr/bin/unrar-alpine /usr/bin/unrar

# ports and volumes
EXPOSE 8000
VOLUME /config
