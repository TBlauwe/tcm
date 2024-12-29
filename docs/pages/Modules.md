# Modules


## Emscripten

In order to use __[Emscripten](https://emscripten.org)__, you must install it on your system.
See __[Emscripten](https://github.com/emscripten-core/emscripten/blob/main/cmake/Modules/Platform/Emscripten.cmake)__, on how to use it with CMake.

> _TL;DR: Provide Emscripten's toolchain to CMake.
> One way is to pass `CMAKE_TOOLCHAIN_FILE "$env{EMROOT}/cmake/Modules/Platform/emscripten.cmake"`
> `EMROOT` is a variable environment (name may differ) set to the root of emscripten's install directory._

````cmake
cmake_minimum_required(VERSION 3.25)

add_executable(test_emscripten main.cpp)
tcm_target_setup_for_emscripten(test_emscripten
        [SHELL_FILE  ...]   # Override default shell file.
        [ASSETS_DIR     ]   # Specify an assets directory if you want to copy it alongside output.
)

#NOTE: If you want to open a .html, you may use emrum, a tool provided by emscripten.
#Here is a utility target to open generated .html
add_custom_target(open_html COMMAND emrun "$<TARGET:RUNTIME_OUTPUT_DIRECTORY>/test_emscripten.html")
add_dependencies(open_html test_emscripten)
````

___

## A note about ISPC

Since CMake +3.19, __[ISPC](https://ispc.github.io/downloads.html)__ is straightforward to use :
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
However, by default, a library with `.ispc` files doesn't include `ISPC_HEADER_DIRECTORY`, so the following is needed.

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

___

### Logging


___

### Miscellenaous functions


___

### Variables

Following variables are available after including `tcm.cmake` or calling `tcm_setup()`.

| Name                       | Description                                                                                                                                        |
|----------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------|
| TCM_SUPPORT_COMPUTED_GOTOS | Some compiler, like MSVC, don't support them (useful for direct threaded VM.)                                                                      |
| TCM_WARNING_GUARD          | Expand to `SYSTEM` when project is consumed to prevent warnings.<br/>Usage: `target_include_directories(_target ${TCM_WARNING_GUARD} PUBLIC dir/)` |
 
