#include "foo.h"

#include <catch2/catch_test_macros.hpp>

TEST_CASE("Foo prints hello", "[foo]")
{
    Foo foo;
    REQUIRE(foo.printHelloWorld() == 0);
}
