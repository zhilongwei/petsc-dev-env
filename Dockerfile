FROM debian:12.8

RUN apt-get update && apt-get install -y \
		build-essential \
		gfortran \
		python3 \
		git \
		cmake \
		clang-format \
		flex \
		doxygen \
		graphviz && \
	apt-get clean && \
    rm -rf /var/lib/apt/lists/*
		
ENV PETSC_DIR=/petsc
ENV PETSC_ARCH=arch-linux-c-noncomplex-debug

RUN git clone -b release https://gitlab.com/petsc/petsc.git ${PETSC_DIR} &&\
    cd ${PETSC_DIR} &&\
	# Anchor to a release version
    git checkout v3.21.1

RUN cd ${PETSC_DIR} && \
		./configure PETSC_ARCH=${PETSC_ARCH} --with-cc=gcc \
		--with-cxx=g++ \
		--with-fc=gfortran \
		--download-mpich \
		--download-fblaslapack \
		--download-superlu \
		--download-superlu_dist \
		--download-mumps \
		--download-scalapack \
		--download-parmetis \
		--download-metis \
		--download-ptscotch \
		--download-bison \
		--download-eigen \
		--download-hdf5 && \
	make PETSC_DIR=${PETSC_DIR} PETSC_ARCH=${PETSC_ARCH} all && \
	make PETSC_DIR=${PETSC_DIR} PETSC_ARCH=${PETSC_ARCH} check

# Install Google Test
RUN git clone https://github.com/google/googletest.git /googletest && \
    cd /googletest && \
    mkdir build && cd build && \
    cmake .. && \
    make && \
    make install && \
    ldconfig