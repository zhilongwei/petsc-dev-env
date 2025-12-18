#include "foo.h"
#include <petscsys.h>

static char help[] = "Main to test\n\n";

int main(int argc, char **argv)
{
    PetscCall(PetscInitialize(&argc, &argv, nullptr, help));

    PetscCall(PetscPrintf(PETSC_COMM_WORLD, "Hello, world from main!\n"));

    Foo foo;
    PetscCall(foo.printHelloWorld());

    PetscCall(PetscFinalize());

    return 0;
}