#include <catch2/catch_session.hpp>
#include <petscsys.h>

int main(int argc, char **argv)
{
    PetscErrorCode ierr = PetscInitialize(&argc, &argv, nullptr, nullptr);
    if (ierr != 0)
    {
        return ierr;
    }

    int result = Catch::Session().run(argc, argv);

    ierr = PetscFinalize();
    if (ierr != 0)
    {
        return ierr;
    }

    return result;
}
