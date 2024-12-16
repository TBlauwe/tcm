#include <benchmark/benchmark.h>

static void BM_noop(benchmark::State& state)
{
    for (auto _: state)
    {
    }
}

BENCHMARK(BM_noop);