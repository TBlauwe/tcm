#include <catch2/catch_test_macros.hpp>
#include <my_lib/my_lib.h>

TEST_CASE("Simple Test")
{
  CHECK(true);
  CHECK_FALSE(my_lib_value());
  CHECK_FALSE(false);
}
