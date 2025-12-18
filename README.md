# PetscFoo

Simple PETSc-based C++ application(s) with Catch2 tests.

## Prerequisites

- PETSc installed (this repo assumes `/opt/petsc` with `PETSC_ARCH=arch-linux-c-debug` in the
  provided container)
- CMake >= 3.16
- pkg-config
- MPI
- Catch2 v3 (installed in the container)

The build uses pkg-config to locate PETSc. If PETSc is not in the container's default
location, set:

```
export PETSC_DIR=/path/to/petsc
export PETSC_ARCH=arch-linux-c-debug
```

## Build

```
cmake -S . -B build
cmake --build build
```

## Run

```
./build/main
```

## Test

```
cmake -S . -B build -DENABLE_TESTS=ON
cmake --build build
ctest --test-dir build --output-on-failure
```
