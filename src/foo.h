#pragma once

#include <petscsys.h>

/**
 * @class Foo
 * @brief A class that provides a method to print "Hello, World!".
 *
 * The Foo class is a simple example class that includes a method to print
 * "Hello, World!" using PETSc's error handling system. The class is
 * non-copyable and non-assignable.
 */

class Foo
{
    public:
        /**
         * @brief Default constructor.
         */
        Foo() = default;

        /**
         * @brief Deleted copy constructor.
         */
        Foo(const Foo &) = delete;

        /**
         * @brief Deleted copy assignment operator.
         */
        Foo &operator=(const Foo &) = delete;

        /**
         * @brief Default destructor.
         */
        ~Foo() = default;

        /**
         * @brief Prints "Hello, World!".
         *
         * This method prints "Hello, World!" using PETSc's error handling
         * system.
         *
         * @return PetscErrorCode Returns 0 on success, or a non-zero error code
         * on failure.
         */
        PetscErrorCode printHelloWorld() const;
};
