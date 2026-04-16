# PetscFoo

Simple PETSc-based C++ application(s) with Catch2 tests.

## Prerequisites

- PETSc installed
- CMake >= 3.16
- pkg-config
- MPI
- Catch2 v3 for test builds
- `clang-format`, `clang-tidy`, and `valgrind` for the optional helper targets

The build uses pkg-config to locate PETSc via:

```text
${PETSC_DIR}/${PETSC_ARCH}/lib/pkgconfig/petsc.pc
```

The provided container usually exposes:

```sh
export PETSC_DIR=/opt/petsc
export PETSC_ARCH=arch-linux-c-debug
```

If your PETSc installation lives elsewhere, set those environment variables before
configuring. `PETSC_ARCH` is the architecture directory created by your PETSc build.

## Automated Workflow

The default automated path is the `debug-tests` preset:

```sh
cmake --preset debug-tests
cmake --build --preset debug-tests
ctest --preset debug-tests
```

That preset enables tests and generates `compile_commands.json` for editor tooling.

## Useful Targets

Once a preset is configured, CMake exposes helper targets for the common workflows:

```sh
cmake --build --preset debug-tests --target format
cmake --build --preset debug-tests --target format-check
cmake --build --preset debug-tests --target tidy
cmake --build --preset debug-tests --target check
cmake --build --preset debug --target run-main
cmake --build --preset debug --target memcheck-main
```

## VS Code

The workspace is configured to use CMake presets directly. The task runner exposes:

- `CMake: build`
- `CMake: build (tests)`
- `Run: main`
- `CTest: run`
- `Clang-Format: apply`
- `Clang-Format: check`
- `Clang-Tidy: check`
- `Valgrind: app`
- `QA: verify`

`QA: verify` runs formatting checks, clang-tidy, and the test suite in sequence.

## Dev Container

The dev container runs `cmake --preset debug-tests` after creation so the test-enabled
build tree and compilation database are available immediately.
