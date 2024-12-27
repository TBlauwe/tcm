# Module : Benchmarking

This module provides a single function for benchmarking using __[Google Benchmarks](https://github.com/google/benchmark)__.

```cmake
tcm_benchmarks (
        [NAME <name>] 
        FILES <file>...
)
```
If no `NAME` is provided, then sources files are added to default target `tcm_Benchmarks`.
Otherwise, a target with provided name is created.
Every target is linked with `benchmark::benchmark_main`, so no need to provide a `main` function.
Multiple calls with the same target will just add sources files to the target.

#### Example

```cmake
tcm_benchmarks(FILES benchmark_1.cpp benchmark_2.cpp) # Added to default target `tcm_Benchmarks`
tcm_benchmarks(NAME my_target FILES benchmark_1.cpp benchmark_2.cpp) # Added to target `my_target`
```

If you wish to override __[Google Benchmarks](https://github.com/google/benchmark)__, do the following once before calling `tcm_benchmarks`:

```cmake
tcm_setup_benchmark(GOOGLE_BENCHMARK_VERSION "vX.X.X")
```


