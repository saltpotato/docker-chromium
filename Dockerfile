
FROM alpine:3.14 AS membarrier
WORKDIR /tmp
COPY membarrier_check.c .
RUN apk --no-cache add build-base linux-headers
RUN gcc -static -o membarrier_check membarrier_check.c
RUN strip membarrier_check

FROM jlesage/baseimage-gui:alpine-3.21-v4.7.0

ARG DOCKER_IMAGE_VERSION=

# add chromium
RUN add-pkg --no-cache chromium

RUN \
    add-pkg \
        # WebGL support.
        mesa-dri-gallium \
        # Audio support.    
        libpulse \
        # Icons used by folder/file selection window (when saving as).
        adwaita-icon-theme \
        # A font is needed.
        font-dejavu \
        # The following package is used to send key presses to the X process.
        xdotool \
        mesa-egl \
        mesa-gl \
        && \
    # Remove unneeded icons.
    find /usr/share/icons/Adwaita -type d -mindepth 1 -maxdepth 1 -not -name 16x16 -not -name scalable -exec rm -rf {} ';' && \
    true

RUN add-pkg fontconfig ttf-freefont

RUN \
    APP_ICON_URL=https://www.chromium.org/_assets/icon-chromium-96.png && \
    install_app_icon.sh "$APP_ICON_URL"

# Add files.

COPY rootfs/ /
#add executable flag to /startapp.sh
RUN chmod +x /startapp.sh
COPY --from=membarrier /tmp/membarrier_check /usr/bin/

# fetch chromium version

RUN \
    CHROMIUM_VERSION=$(/usr/bin/chromium-browser --version | cut -d ' ' -f 2) && \
    DOCKER_IMAGE_VERSION=$(date +'%Y%m%d') && \
    echo "Chromium version: $CHROMIUM_VERSION" && \
    echo "Docker image version: $DOCKER_IMAGE_VERSION" && \
    true

RUN \
    set-cont-env APP_NAME "Chromium" && \
    set-cont-env APP_VERSION "$(/usr/bin/chromium-browser --version | cut -d ' ' -f 2)" && \
    set-cont-env DOCKER_IMAGE_VERSION "$(date +'%Y%m%d')" && \
    true
RUN add-pkg --update util-linux

ENV CHROMIUM_CUSTOM_ARGS="--disable-vulkan --disable-gpu"

# Metadata.
LABEL \
      org.label-schema.name="chromium" \
      org.label-schema.description="Docker container for chromium" \
      org.label-schema.version="${DOCKER_IMAGE_VERSION:-unknown}" \
      org.label-schema.vcs-url="" \
      org.label-schema.schema-version="1.0"