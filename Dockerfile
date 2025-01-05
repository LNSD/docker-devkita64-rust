# Devkitpro Docker image with Rust installed
#
# The base image is the devkitpro/devkita64 image, which is a Debian-slim image with the devkitA64 toolchain installed.
# See: https://github.com/devkitPro/docker/blob/8a389fe378f7adf37605975f5d257c5785966196/toolchain-base/Dockerfile#L1

# Base image build arguments
ARG DEVKITA64_VERSION=latest

### Main image build
FROM devkitpro/devkita64:${DEVKITA64_VERSION}

ARG RUSTUP_VERSION=1.27.1
ARG RUST_VERSION

# Code borrowed with modifications from the official Rust Docker image
# Source: https://github.com/rust-lang/docker-rust/blob/fab440ae8329bc7bf680deb26e8679e7028c0536/Dockerfile-slim.template
ENV RUSTUP_HOME=/usr/local/rustup \
    CARGO_HOME=/usr/local/cargo \
    PATH=/usr/local/cargo/bin:$PATH \
    RUST_VERSION=${RUST_VERSION}

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        gcc \
        libc6-dev \
        curl \
        ; \
    dpkgArch="$(dpkg --print-architecture)"; \
    case "${dpkgArch##*-}" in \
      amd64) rustArch='x86_64-unknown-linux-gnu' ;; \
      arm64) rustArch='aarch64-unknown-linux-gnu' ;; \
      *) echo >&2 "unsupported architecture: ${dpkgArch}"; exit 1 ;; \
    esac; \
    curl -O "https://static.rust-lang.org/rustup/archive/${RUSTUP_VERSION}/$rustArch/rustup-init"; \
    curl -s "https://static.rust-lang.org/rustup/archive/${RUSTUP_VERSION}/$rustArch/rustup-init.sha256" | awk '{print $1, "*rustup-init"}' | sha256sum -c -; \
    chmod +x rustup-init; \
    ./rustup-init -y --no-modify-path --profile minimal --default-toolchain ${RUST_VERSION} --default-host $rustArch; \
    rm rustup-init; \
    chmod -R a+w $RUSTUP_HOME $CARGO_HOME; \
    rustup --version; \
    cargo --version; \
    rustc --version; \
    apt-get remove -y --auto-remove \
        curl \
        ; \
    rm -rf /var/lib/apt/lists/*;
