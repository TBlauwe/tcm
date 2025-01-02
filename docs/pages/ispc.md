# ISPC

Since CMake 3.19, __[ISPC](https://ispc.github.io/downloads.html)__ is straightforward to use :
* make sure to install __[ISPC](https://ispc.github.io/downloads.html)__ and add its executable to `path`,
* `.ispc` files can be added as regular sources files to a target, e.g. for `tests/ispc/` :

```cmake
project(TEST_Ispc 
        LANGUAGES
            C CXX
            ISPC    # REQUIRED 
)
add_library(ispc_lib STATIC simple.ispc)
```

Following properties are overridable:
* `ISPC_HEADER_DIRECTORY` per target, or `CMAKE_ISPC_HEADER_DIRECTORY` globally (default `CMAKE_CURRENT_BINARY`).
* `ISPC_HEADER_SUFFIX` per target, or `CMAKE_ISPC_HEADER_SUFFIX` globally (default `_ispc.h`).
* `ISPC_INSTRUCTION_SETS` per target, or `CMAKE_ISPC_INSTRUCTION_SETS` globally (default should be the most capable one if we follow [ispc's documentation](https://ispc.github.io/ispc.html#using-the-ispc-compiler)).

There are nothing else to do for executable targets.
However, by default, a library with `.ispc` files doesn't include `ISPC_HEADER_DIRECTORY`, so the following is needed:

```cmake
target_include_directories(ispc_lib PUBLIC $<TARGET_PROPERTY:ISPC_HEADER_DIRECTORY>)
```

If you want to change a property, use
```cmake
set_target_property(ispc_lib PROPERTIES ISPC_HEADER_DIRECTORY ...)
```

TCM provide a single convenience function to set these for a target through function's parameters.

```cmake
tcm_target_setup_ispc(your_target 
        [ISPC_HEADER_DIRECTORY $<TARGET_PROPERTY:ISPC_HEADER_DIRECTORY>]
        [ISPC_HEADER_SUFFIX "_ispc.h"]
        [ISPC_INSTRUCTION_SETS "most capable one by default"] 
)
```
