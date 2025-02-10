#include "foo.h"
#include <gtest/gtest.h>

/**
 * @brief Unit test for Foo::printHelloWorld method.
 *
 * This test case creates an instance of the Foo class and calls the
 * printHelloWorld method. It expects the method to return 0, indicating
 * success.
 */
TEST(FooTest, PrintHelloWorld)
{
    Foo foo;
    EXPECT_EQ(foo.printHelloWorld(), 0);
}