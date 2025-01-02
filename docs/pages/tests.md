# Tests 

__TCM__ provides a single function for testing using __[Catch2](https://github.com/catchorg/Catch2)__.

```cmake
tcm_tests (
        [NAME <name>] 
        FILES <file>...
)
```
If no `NAME` is provided, then sources files are added to default target `${PROJECT_NAME}_Tests`.
Otherwise, a target with provided name is created.
Every target is linked with `Catch2::Catch2WithMain`, so no need to provide a `main` function.
Multiple calls with the same target will just add sources files to the target.

#### Example

```cmake
tcm_tests(FILES test_1.cpp test_2.cpp) # Added to default target `tcm_tests`
tcm_tests(NAME my_test FILES test_1.cpp test_2.cpp) # Added to target `my_target`
```

If you wish to override __[Catch2](https://github.com/catchorg/Catch2)__, do the following once before calling `${PROJECT_NAME}_Tests`:

```cmake
tcm_setup_test(CATCH2_VERSION "vX.X.X")
```
