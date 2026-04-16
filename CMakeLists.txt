cmake_minimum_required(VERSION 3.16)

project(PetscFoo LANGUAGES C CXX)

# Export compile_commands.json so clangd sees include paths from PETSc and other deps
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

option(ENABLE_TESTS "Build tests" OFF)

function(resolve_cache_or_env out_var cache_name env_name default_value)
    if (DEFINED ${cache_name} AND NOT "${${cache_name}}" STREQUAL "")
        set(_value "${${cache_name}}")
    elseif (DEFINED ENV{${env_name}} AND NOT "$ENV{${env_name}}" STREQUAL "")
        set(_value "$ENV{${env_name}}")
    else()
        set(_value "${default_value}")
    endif()

    set(${out_var} "${_value}" PARENT_SCOPE)
endfunction()

resolve_cache_or_env(_petsc_dir PETSC_DIR PETSC_DIR "/opt/petsc")
set(PETSC_DIR "${_petsc_dir}" CACHE PATH "PETSc installation prefix" FORCE)

resolve_cache_or_env(_petsc_arch PETSC_ARCH PETSC_ARCH "arch-linux-c-debug")
set(PETSC_ARCH "${_petsc_arch}" CACHE STRING "PETSc architecture directory" FORCE)

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

add_library(foo
    src/foo.cc
)
target_include_directories(foo
    PUBLIC
        ${CMAKE_CURRENT_SOURCE_DIR}/src
)
target_link_libraries(foo
    PUBLIC
        PkgConfig::PETSC
        MPI::MPI_CXX
)

add_executable(main
    src/apps/main.cc
)
target_link_libraries(main PRIVATE foo)

if (ENABLE_TESTS)
    find_package(Catch2 3 REQUIRED)
    enable_testing()

    add_library(test_main OBJECT
        tests/test_main.cc
    )
    target_link_libraries(test_main
        PRIVATE
            PkgConfig::PETSC
            MPI::MPI_CXX
            Catch2::Catch2
    )

    add_executable(test_foo
        tests/test_foo.cc
        $<TARGET_OBJECTS:test_main>
    )
    target_link_libraries(test_foo
        PRIVATE
            foo
            Catch2::Catch2
    )

    add_test(NAME foo COMMAND test_foo)

    add_custom_target(check
        COMMAND "${CMAKE_CTEST_COMMAND}" --output-on-failure
        WORKING_DIRECTORY "${CMAKE_BINARY_DIR}"
        DEPENDS test_foo
        USES_TERMINAL
        COMMENT "Running the test suite"
        VERBATIM
    )
endif()

file(GLOB_RECURSE PROJECT_SOURCE_FILES CONFIGURE_DEPENDS
    "${CMAKE_CURRENT_SOURCE_DIR}/src/*.cc"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/*.h"
    "${CMAKE_CURRENT_SOURCE_DIR}/tests/*.cc"
    "${CMAKE_CURRENT_SOURCE_DIR}/tests/*.h"
)
list(SORT PROJECT_SOURCE_FILES)

set(PROJECT_TIDY_FILES
    "${CMAKE_CURRENT_SOURCE_DIR}/src/foo.cc"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/apps/main.cc"
)
if (ENABLE_TESTS)
    list(APPEND PROJECT_TIDY_FILES
        "${CMAKE_CURRENT_SOURCE_DIR}/tests/test_main.cc"
        "${CMAKE_CURRENT_SOURCE_DIR}/tests/test_foo.cc"
    )
endif()

find_program(CLANG_FORMAT_BIN NAMES clang-format)
if (CLANG_FORMAT_BIN)
    add_custom_target(format
        COMMAND "${CLANG_FORMAT_BIN}" -i ${PROJECT_SOURCE_FILES}
        WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
        COMMENT "Formatting project sources"
        VERBATIM
    )

    add_custom_target(format-check
        COMMAND "${CLANG_FORMAT_BIN}" --dry-run --Werror ${PROJECT_SOURCE_FILES}
        WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
        COMMENT "Checking project formatting"
        VERBATIM
    )
else()
    message(STATUS "clang-format not found; format targets will be unavailable")
endif()

find_program(CLANG_TIDY_BIN NAMES clang-tidy)
if (CLANG_TIDY_BIN)
    add_custom_target(tidy
        COMMAND "${CLANG_TIDY_BIN}" -p "${CMAKE_BINARY_DIR}" ${PROJECT_TIDY_FILES}
        WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
        COMMENT "Running clang-tidy"
        VERBATIM
    )
else()
    message(STATUS "clang-tidy not found; tidy target will be unavailable")
endif()

add_custom_target(run-main
    COMMAND "$<TARGET_FILE:main>"
    DEPENDS main
    WORKING_DIRECTORY "${CMAKE_BINARY_DIR}"
    USES_TERMINAL
    COMMENT "Running the main application"
    VERBATIM
)

find_program(VALGRIND_BIN NAMES valgrind)
if (VALGRIND_BIN)
    add_custom_target(memcheck-main
        COMMAND "${VALGRIND_BIN}" --leak-check=full --show-leak-kinds=all --error-exitcode=1 "$<TARGET_FILE:main>"
        DEPENDS main
        WORKING_DIRECTORY "${CMAKE_BINARY_DIR}"
        USES_TERMINAL
        COMMENT "Running valgrind on the main application"
        VERBATIM
    )
else()
    message(STATUS "valgrind not found; memcheck target will be unavailable")
endif()
