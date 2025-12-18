FROM debian:bookworm-slim

ARG DEBIAN_FRONTEND=noninteractive
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ARG PETSC_BUILD_TYPE=debug   # debug (default) or release
ARG PETSC_REF=release        # release (default) or e.g. v3.24.2
ARG CATCH2_REF=v3.5.4

ENV PETSC_DIR=/opt/petsc \
    PETSC_ARCH=arch-linux-c-${PETSC_BUILD_TYPE} \
    PATH=/opt/petsc/arch-linux-c-${PETSC_BUILD_TYPE}/bin:/opt/petsc/bin:${PATH}

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        ca-certificates curl wget git \
        build-essential gfortran cmake ninja-build pkg-config \
        python3 python3-pip python3-venv python3-numpy \
        clangd clang-tidy clang-format valgrind gdb \
        patch unzip xz-utils bzip2 \
        perl m4 flex \
    ; \
    rm -rf /var/lib/apt/lists/*

RUN set -eux; \
    git clone --depth 1 --branch "${PETSC_REF}" https://gitlab.com/petsc/petsc.git "${PETSC_DIR}"

RUN set -eux; \
    cd "${PETSC_DIR}"; \
    if [[ "${PETSC_BUILD_TYPE}" =~ ^([Rr]elease)$ ]]; then \
      WITH_DEBUGGING=0; OPTFLAGS="-O3"; \
    else \
      WITH_DEBUGGING=1; OPTFLAGS="-O0 -g"; \
    fi; \
    ./configure \
      PETSC_ARCH="${PETSC_ARCH}" \
      --with-debugging="${WITH_DEBUGGING}" \
      --with-shared-libraries=1 \
      --with-cc=gcc --with-cxx=g++ --with-fc=gfortran \
      --download-mpich \
      --download-fblaslapack \
      --download-superlu \
      --download-superlu_dist \
      --download-parmetis \
      --download-metis \
      --download-bison \
      --download-eigen \
      --download-hdf5 \
      COPTFLAGS="${OPTFLAGS}" CXXOPTFLAGS="${OPTFLAGS}" FOPTFLAGS="${OPTFLAGS}" \
    ; \
    make -j"$(nproc)" PETSC_DIR="${PETSC_DIR}" PETSC_ARCH="${PETSC_ARCH}" all; \
    make PETSC_DIR="${PETSC_DIR}" PETSC_ARCH="${PETSC_ARCH}" check; \
    rm -rf "${PETSC_DIR}/.git"

RUN set -eux; \
    git clone --depth 1 --branch "${CATCH2_REF}" https://github.com/catchorg/Catch2.git /tmp/Catch2; \
    cmake -S /tmp/Catch2 -B /tmp/Catch2/build \
      -DCMAKE_BUILD_TYPE=Release \
      -DBUILD_TESTING=OFF \
      -DCMAKE_INSTALL_PREFIX=/usr/local; \
    cmake --build /tmp/Catch2/build -j"$(nproc)"; \
    cmake --install /tmp/Catch2/build; \
    rm -rf /tmp/Catch2

WORKDIR /workspace
CMD ["/bin/bash"]