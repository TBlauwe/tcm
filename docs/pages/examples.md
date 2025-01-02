# Examples

__TCM__ provides a single function for defining standalone examples.

```cmake
tcm_examples (
        FILES <file_or_folder> ... 
        [WITH_BENCHMARK]
        [INTERFACE <a_target>]
)
```

All source files will be compiled as a target
You shouldn't use it for "complex" examples, where some .cpp files do not provide a main entry point.
- Each example defines a new target, named : `<relative_path_to_examples_folder>_filename`
- Each example is added to CTest
- Each example executable is outputted to ${TCM_EXE_DIR}/examples.

If `WITH_BENCHMARK` is passed, then each example will be added to default target `tcm_Benchmarks`.
For this to work, some source manipulation is done.
A new source file is created, where the entry point, `main()`, (must take no arguments !) is replaced to a standalone function.
The new source file call the newly function inside a benchmarkable boilerplate.

If `INTERFACE` is set to a library target (interface or not), then each example will link to it.
If this is not enough, each call to `tcm_examples` will produce a list of targets `TCM_EXAMPLES_TARGET`.
You can iterate through it and manually set properties.

#### Example

Full example available at `tests/examples`.

```cmake
tcm_examples(FILES examples WITH_BENCHMARK)
```
