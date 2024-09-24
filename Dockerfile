# Dockerfile
FROM fedora:39
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
    git
RUN git clone https://github.com/emscripten-core/emsdk.git /emsdk
RUN /emsdk/emsdk install 3.1.67
RUN /emsdk/emsdk activate 3.1.67
RUN echo 'source "/emsdk/emsdk_env.sh"' >> $HOME/.bashrc
RUN git clone https://github.com/tpoechtrager/osxcross.git /osxcross
RUN curl -o /osxcross/tarballs/MacOSX15.0.sdk.tar.xz -L https://github.com/V-Sekai/world/releases/download/v0.0.1/MacOSX15.0.sdk.tar.xz
RUN cd  /osxcross && UNATTENDED=1 ./build.sh && ./build_compiler_rt.sh
RUN curl -o llvm-mingw.tar.xz -L https://github.com/mstorsjo/llvm-mingw/releases/download/20240917/llvm-mingw-20240917-ucrt-ubuntu-20.04-aarch64.tar.xz
RUN tar -xf llvm-mingw.tar.xz -C /
RUN rm -rf llvm-mingw.tar.xz 
WORKDIR /app
CMD ["bash"]
