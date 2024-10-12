FROM fedora:39

ARG FETCH_SDKS=false

RUN dnf install -y \
    xz \
    gcc \
    gcc-c++ \
    zlib-devel \
    libmpc-devel \
    mpfr-devel \
    gmp-devel \
    clang \
    just \
    parallel \
    scons \
    mold \
    pkgconfig \
    libX11-devel \
    libXcursor-devel \
    libXrandr-devel \
    libXinerama-devel \
    libXi-devel \
    wayland-devel \
    mesa-libGL-devel \
    mesa-libGLU-devel \
    alsa-lib-devel \
    pulseaudio-libs-devel \
    libudev-devel \
    libstdc++-static \
    libatomic-static \
    cmake \
    patch \
    libxml2-devel \
    openssl \
    openssl-devel \
    git \
    unzip

RUN if [ "$FETCH_SDKS" = "true" ]; then \
        curl -o llvm-mingw.tar.xz -L https://github.com/mstorsjo/llvm-mingw/releases/download/20240917/llvm-mingw-20240917-ucrt-ubuntu-20.04-x86_64.tar.xz; \
        tar -xf llvm-mingw.tar.xz -C /; \
        rm -rf llvm-mingw.tar.xz; \
    fi

ENV JAVA_HOME="/jdk"
RUN if [ "$FETCH_SDKS" = "true" ]; then \
        curl --fail --location --silent --show-error "https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.11%2B9/OpenJDK17U-jdk_$(uname -m | sed -e s/86_//g)_linux_hotspot_17.0.11_9.tar.gz" --output /tmp/jdk.tar.gz; \
        mkdir -p /jdk; \
        tar -xf /tmp/jdk.tar.gz -C /jdk --strip 1; \
        rm -rf /tmp/jdk.tar.gz; \
    fi

ENV ANDROID_SDK_ROOT=/root/sdk
ENV ANDROID_NDK_VERSION=23.2.8568313
ENV ANDROID_NDK_ROOT=${ANDROID_SDK_ROOT}/ndk/${ANDROID_NDK_VERSION}
RUN mkdir -p sdk && cd sdk && \
    export CMDLINETOOLS=commandlinetools-linux-11076708_latest.zip && \
    if [ "$FETCH_SDKS" = "true" ]; then \
        curl -LO https://dl.google.com/android/repository/${CMDLINETOOLS}; \
        unzip ${CMDLINETOOLS}; \
        rm ${CMDLINETOOLS}; \
    fi && \
    yes | cmdline-tools/bin/sdkmanager --sdk_root="${ANDROID_SDK_ROOT}" --licenses && \
    cmdline-tools/bin/sdkmanager --sdk_root="${ANDROID_SDK_ROOT}" "ndk;${ANDROID_NDK_VERSION}" 'cmdline-tools;latest' 'build-tools;34.0.0' 'platforms;android-34' 'cmake;3.22.1'

RUN if [ "$FETCH_SDKS" = "true" ]; then \
        curl -O https://download.blender.org/release/Blender4.1/blender-4.1.1-linux-x64.tar.xz; \
        tar -xf blender-4.1.1-linux-x64.tar.xz -C /opt/; \
        rm blender-4.1.1-linux-x64.tar.xz; \
    fi && \
    ln -s /opt/blender-4.1.1-linux-x64/blender /usr/local/bin/blender

RUN mkdir -p /opt/cargo /opt/rust && curl https://sh.rustup.rs -sSf | sh -s -- -y --default-toolchain nightly --no-modify-path && . "$HOME/.cargo/env" && rustup default nightly && rustup target add aarch64-linux-android x86_64-linux-android x86_64-unknown-linux-gnu aarch64-apple-ios x86_64-apple-ios x86_64-apple-darwin aarch64-apple-darwin x86_64-pc-windows-gnu x86_64-pc-windows-msvc wasm32-wasi

RUN git clone https://github.com/emscripten-core/emsdk.git /emsdk \
    && /emsdk/emsdk install 3.1.67 \
    && /emsdk/emsdk activate 3.1.67 \
    && echo 'source "/emsdk/emsdk_env.sh"' >> $HOME/.bashrc

RUN git clone https://github.com/tpoechtrager/osxcross.git /osxcross

RUN if [ "$FETCH_SDKS" = "true" ]; then \
    curl -o /osxcross/tarballs/MacOSX15.0.sdk.tar.xz -L https://github.com/V-Sekai/world/releases/download/v0.0.1/MacOSX15.0.sdk.tar.xz && \
    ls -l /osxcross/tarballs/; \
    fi

RUN cd /osxcross && UNATTENDED=1 ./build.sh && ./build_compiler_rt.sh

WORKDIR /app
CMD ["bash"]
