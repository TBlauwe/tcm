#include <benchmark/benchmark.h>

#include <my_lib/my_lib.h>

static void BM_my_lib_value(benchmark::State& state)
{
    for (auto _: state)
    {
        my_lib_value();
    }
}

BENCHMARK(BM_my_lib_value);