# petsc-dev-env

A Docker-based environment for PETSc application development in debugging mode, offering:

* Docker builds from a Dockerfile
* Git version control
* Doxygen documentation
* Google Test integration
* Automatic clang-format
* Easy project migration
* VS Code remote container support

## Usage
1. Build the Docker image from the `Dockerfile`.
    By default, the Dockerfile uses the latest PETSc release. If you need a specific version, edit the Dockerfile to pin a release version, then run:
    ```bash
    docker build -t petsc:vMAJOR.MINOR.PATCH-debug .
    ```

2. Update `.devcontainer/devcontainer.json` 
    Specify the correct image name in the `image` field, for example
    ```json
    "image": "petsc:vMAJOR.MINOR.PATCH-debug"
    ```

3. Open in Container (VS Code).
    In Visual Studio Code, use the “Remote-Containers: Open Folder in Container…” command to start working with the PETSc dev environment.