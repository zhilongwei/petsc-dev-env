cmake_minimum_required(VERSION 3.16)

project(PetscFoo LANGUAGES C CXX)

# Export compile_commands.json so clangd sees include paths from PETSc and other deps
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

set(CMAKE_CXX_EXTENSIONS OFF)

option(ENABLE_TESTS "Build tests" OFF)

if (DEFINED ENV{PETSC_DIR})
    set(PETSC_DIR "$ENV{PETSC_DIR}" CACHE PATH "PETSc installation prefix")
else()
    set(PETSC_DIR "/opt/petsc" CACHE PATH "PETSc installation prefix")
endif()

if (DEFINED ENV{PETSC_ARCH})
    set(PETSC_ARCH "$ENV{PETSC_ARCH}" CACHE STRING "PETSc architecture directory")
else()
    set(PETSC_ARCH "arch-linux-c-debug" CACHE STRING "PETSc architecture directory")
endif()

set(_petsc_pc_dir "${PETSC_DIR}/${PETSC_ARCH}/lib/pkgconfig")
if (EXISTS "${_petsc_pc_dir}/petsc.pc")
    if (DEFINED ENV{PKG_CONFIG_PATH} AND NOT "$ENV{PKG_CONFIG_PATH}" STREQUAL "")
        set(ENV{PKG_CONFIG_PATH} "${_petsc_pc_dir}:$ENV{PKG_CONFIG_PATH}")
    else()
        set(ENV{PKG_CONFIG_PATH} "${_petsc_pc_dir}")
    endif()
endif()

find_package(PkgConfig REQUIRED)
pkg_check_modules(PETSC REQUIRED IMPORTED_TARGET petsc)
find_package(MPI REQUIRED)

set(COMMON_SOURCES
    src/foo.cc
)

set(PETSC_APPS
    main
)

foreach(app IN LISTS PETSC_APPS)
    add_executable(${app}
        src/apps/${app}.cc
        ${COMMON_SOURCES}
    )
    target_compile_features(${app} PRIVATE cxx_std_17)
    target_include_directories(${app} PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}/src
    )
    target_link_libraries(${app} PRIVATE PkgConfig::PETSC MPI::MPI_CXX)
endforeach()

if (ENABLE_TESTS)
    find_package(Catch2 3 REQUIRED)
    enable_testing()

    add_library(test_main OBJECT
        tests/test_main.cc
    )
    target_compile_features(test_main PRIVATE cxx_std_17)
    target_link_libraries(test_main PRIVATE PkgConfig::PETSC MPI::MPI_CXX Catch2::Catch2)

    add_executable(test_foo
        tests/test_foo.cc
        ${COMMON_SOURCES}
        $<TARGET_OBJECTS:test_main>
    )
    target_compile_features(test_foo PRIVATE cxx_std_17)
    target_include_directories(test_foo PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}/src
    )
    target_link_libraries(test_foo PRIVATE PkgConfig::PETSC MPI::MPI_CXX Catch2::Catch2)
    add_test(NAME foo COMMAND test_foo)
endif()
