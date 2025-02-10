#include "foo.h"

/**
 * @brief Prints "Hello, World!".
 *
 * This method prints "Hello, World!" using PETSc's error handling system.
 *
 * @return PetscErrorCode Returns 0 on success, or a non-zero error code on
 * failure.
 */
PetscErrorCode Foo::printHelloWorld() const
{
    PetscFunctionBeginUser;

    PetscErrorCode ierr;

    ierr = PetscPrintf(PETSC_COMM_WORLD, "Hello, world from Foo!\n");
    CHKERRQ(ierr);

    PetscFunctionReturn(ierr);
}