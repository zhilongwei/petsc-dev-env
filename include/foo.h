// MIT License
//
// Copyright (c) 2025 Zhilong Wei
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

#ifndef FOO_H_
#define FOO_H_

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

#endif // FOO_H_