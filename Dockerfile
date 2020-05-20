FROM alpine:3.11

#############################################
#
# Settings
#
#############################################
ENV LLVM_DOWNLOAD_URL http://releases.llvm.org/8.0.0/llvm-8.0.0.src.tar.xz
ENV LLVM_CBE_DOWNLOAD_URL https://github.com/JuliaComputing/llvm-cbe.git

WORKDIR /

RUN \
    set -e \
#############################################
#
# Install dependencies
#
#############################################
    && apk update \
    && apk add --no-cache --virtual builddep \
        alpine-sdk \
        build-base \
        util-linux-dev \
        python3 \
        ninja \
        cmake \
        wget \
    && apk add --no-cache --virtual rundep \
        libgcc \
        libstdc++ \
#############################################
#
# Download LLVM sources
#
#############################################
    && mkdir -p /tmp \
    && cd /tmp \
    && wget ${LLVM_DOWNLOAD_URL} \
    && tar xJf llvm-8.0.0.src.tar.xz \
    && mv /tmp/llvm-8.0.0.src /tmp/llvm \
#############################################
#
# Download LLVM-CBE sources
#
#############################################
    && cd /tmp/llvm/projects \
    && git clone ${LLVM_CBE_DOWNLOAD_URL} \
#############################################
#
# Build and install LLVM
#
#############################################
    && mkdir -p /tmp/llvm/build \
    && cd /tmp/llvm/build \
    && cmake -G Ninja -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DCMAKE_BUILD_TYPE=Release .. \
    && ninja \
    && ninja install \
#############################################
#
# Delete sources
#
#############################################
    && cd / \
    && apk del builddep --purge \
    && rm -rf /tmp \
    && rm -rf /var/cache/apk/*
