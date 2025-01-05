# Benchmarks

__TCM__ provides a single function to benchmark using __[Google Benchmarks](https://github.com/google/benchmark)__.

```cmake
tcm_benchmarks (
        [NAME <name>] 
        FILES <file>...
        [LIBRARIES <target> ...]
)
```
If no `NAME` is provided, then sources files are added to default target `${PROJECT_NAME}_Benchmarks`.
Otherwise, a target with provided name is created.

Every target is linked with `benchmark::benchmark_main`, so no need to provide a `main` function.
Multiple calls with the same target will just add sources files to the target.

Benchmark target can also be linked with `LIBRARIES` targets

#### Example

```cmake
tcm_benchmarks(FILES benchmark_1.cpp benchmark_2.cpp) # Added to default target `${PROJECT_NAME}_Benchmarks`
tcm_benchmarks(NAME my_target FILES benchmark_1.cpp benchmark_2.cpp) # Added to target `my_target`
```

If you wish to override __[Google Benchmarks](https://github.com/google/benchmark)__, do the following once before calling `tcm_benchmarks`:

```cmake
tcm_setup_benchmark(GOOGLE_BENCHMARK_VERSION "vX.X.X")
```


