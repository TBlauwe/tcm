# TCM

![CMake](https://img.shields.io/badge/CMake-%23008FBA.svg?style=for-the-badge&logo=cmake&logoColor=white)

A pluggable opinionated CMake script to provide some functionalities shared across C++ projects.
Only use what suits you !

* Setup __[CPM](https://github.com/cpm-cmake/CPM.cmake)__ for dependency management.
* Setup project's version from git in dev mode or from generated `VERSION` file in consumed mode.
* Setup cache using tools like __[ccache](https://ccache.dev/)__.
* Setup documentation with __[Doxygen](https://www.doxygen.nl/)__ (if installed) and __[Doxygen Awesome](https://github.com/jothepro/doxygen-awesome-css)__.
* Setup target to be used with __[Emscripten](https://emscripten.org)__ (if installed).
* Add tests with __[Catch2](https://github.com/catchorg/Catch2)__.
* Add benchmarks with __[Google Benchmarks](https://github.com/google/benchmark)__.
* Add examples with optional benchmarking.
* and some other handy functions.

See [Overview](#overview) below for a closer look.

> [!NOTE]
>
> As most of my other repositories, they are mostly intended for personal usage and learning.
> You are probably better off looking elsewhere, like [awesome cmake](https://github.com/onqtam/awesome-cmake).

__Rationale__ 

C / C++ projects have a lot of boilerplate (for building, packaging, testing, benchmarking, profiling, documentation, etc.)
One solution is to start from a template. Overtime, template will update, fix bugs, bring new functionalities and so on. 
There are ways to sync changes, but there are still some friction, notably with template with generated code.
In some way, we could see this as the inheritance vs composition problem.
This CMake module favors composition over inheritance. 
Choose functionalities you need, without the burden of those you don't need.


## Overview

### CPM

Download and setup .

```cmake 
#set(CPM_SOURCE_CACHE "~/.cpm/")  # You can also set it as an environment variable, so it works across projects.
#set(CPM_DOWNLOAD_VERSION 0.40.2) # Default Value
#set(CPM_HASH_SUM "c8cdc32c03816538ce22781ed72964dc864b2a34a310d3b7104812a5ca2d835d") #Default value
tcm_setup_cpm()
```

___

### Cache

Setup __[ccache](https://ccache.dev/)__, if installed.

```cmake 
tcm_setup_cache()
```

___

### Version setup from Git

Set version from __Git__ if used in top-level project or from generated `VERSION` file.

```cmake 
tcm_setup_project_version()
```

> [!NOTE]
> 
> Support a subset of semantic versioning : major.minor.patch

___


### Automated Doxygen Setup

Setup documentation with [Doxygen](https://www.doxygen.nl/) (if installed) and [Doxygen Awesome](https://github.com/jothepro/doxygen-awesome-css)

```cmake 
tcm_setup_docs()
```
Here what it gives with this repository.

![sample_documentation.png](assets/sample_documentation.png)

Two targets are provided : 

* `docs` - to build documentation
* `open_docs` - to open documentation

Default values should give you suitable results. You may override some doxygen config options by setting them before the call, e.g.:

```cmake
set(DOXYGEN_HTML_EXTRA_STYLESHEET "...")
tcm_setup_docs()
```

> [!NOTE]
> 
> It uses `doxygen_add_docs` under the hood. See `SETUP-DOCUMENTATION` in tcm.cmake (prefer the one in src/ if you have access to the repository).

___


### Add tests

You can easily add tests using __[Catch2](https://github.com/catchorg/Catch2)__.

```cmake 
tcm_add_tests(TARGET a_target_name FILES some_test_files.cpp ...)
```

> [!NOTE]
> 
> Target is linked with Catch2::Catch2WithMain and tests are added to CTest.

---

### Add benchmarks

You can easily add tests add benchmarks with __[Google Benchmarks](https://github.com/google/benchmark)__.

```cmake 
tcm_add_benchmarks(TARGET a_target_name FILES some_benchmark_files.cpp ...)
```

> [!NOTE]
>
> Target is linked with benchmark::benchmark_main.
 
---

### Add examples


Let's say you have a folder called `examples`, with many standalone sources files. Calling `tcm_add_examples`, let's you:
* create a target for each source file,
* each target is added to CTest,
* each target can be linked against an interface target specified with `INTERFACE` parameter.
* each target can be added to `Benchmark_Examples` to benchmark its execution.
  * source file must use an empty main signature, otherwise it is ignored.
  * source file must explicitly return a value, otherwise it won't compile.

```cmake 
tcm_add_examples(
        FOLDER examples/    # Recursively look for .cpp file.
        INTERFACE a_target  # Each example's target will link to this interface (to inherit some properties)
        WITH_BENCHMARK      # If using an empty signature `main()`, then example can be benchmarked.
)
```

> [!NOTE]
>
> Target is linked with benchmark::benchmark_main.
 
___

## Emscripten

In order to use __[Emscripten](https://emscripten.org)__, you must install it on your system.
See __[Emscripten]()__, on how to use it with CMake. 

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

Usual logging functionalities.

```cmake 
set(TCM_VERBOSE ON)                   # Toggleable verbosity

# Usual logging functions
#tcm_error("Abort message." FATAL)    # A FATAL_ERROR message under the hood. 
tcm_error("Expected error message.")  # A STATUS message under the hood.
tcm_warn("Expected warning message.") # A STATUS message under the hood or as AUTHOR_WARNING by adding AUTHOR_WARNING .
tcm_info("An info information.")      # A STATUS message under the hood.
tcm_log("A normal message.")          # A STATUS message under the hood.

set(CMAKE_MESSAGE_LOG_LEVEL TRACE)    # To enable lower-level message.
tcm_debug("A debug message.")
tcm_trace("A trace message.")

# Nestable sections
tcm_begin_section("SECTION")
    tcm_log("A normal message in a section.")
    tcm_begin_section("SUBSECTION")
        tcm_log("A normal message in a subsection.")
    tcm_end_section()
tcm_end_section()

# OUTPUT:
# -- [PROJECT_NAME] [!] Expected error message.
# -- [PROJECT_NAME] /!\ Expected warning message.
# -- [PROJECT_NAME] (!) An info message.
# -- [PROJECT_NAME]     A normal message.
# -- [PROJECT_NAME]     A debug message.
# -- [PROJECT_NAME]     A trace message.
# -- [PROJECT_NAME | SECTION]     A normal message in a section.
# -- [PROJECT_NAME | SECTION | SUBSECTION]     A normal message in a subsection.
```
Some additional functions:
* `tcm_check_start(), tcm_check_pass(), tcm_check_fail()` for check section.
* `tcm_indent(), tcm_outdent()` for indenting/outdenting messages.

___

### Miscellenaous functions

```cmake
tcm_suppress_warnings(_target)
```
Should suppress warnings emitted from `_target`, by adding `SYSTEM` modifier to its include directories.

> [!WARNING]
>
> Doesn't seem to always works.
   
```cmake
tcm_option_define(_target _option)
```
Define `-D${_option}` for `_target` when `_option` is ON.

```cmake
tcm_target_assets(_target _src_dir _dst_dir)
```
Copy folder `_src_dir` to `_dst_dir` before target is built.

```cmake
tcm_generate_export_header(_target)
```

A wrapper over `generate_export_header` with some preferred default, properties set (VERSION, SOVERSION, etc.), and export directory already included.

___

### Variables

Following variables are available after including `tcm.cmake` or calling `tcm_setup()`.

| Name                       | Description                                                                                                                                        |
|----------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------|
| TCM_SUPPORT_COMPUTED_GOTOS | Some compiler, like MSVC, don't support them (useful for direct threaded VM.)                                                                      |
| TCM_WARNING_GUARD          | Expand to `SYSTEM` when project is consumed to prevent warnings.<br/>Usage: `target_include_directories(_target ${TCM_WARNING_GUARD} PUBLIC dir/)` |
 

## Installation

> [!WARNING]
>
> Under construction / Needs testing.
> 
Same instructions as for any single file script (See [CPM's documentation](https://github.com/cpm-cmake/CPM.cmake?tab=readme-ov-file#adding-cpm)).

* Create a directory to hold the script.
 
```bash
mkdir -p cmake
```

* Download either :
  * `get_tcm.cmake` - for a more efficient way to download new version.
  ```bash
  wget -O cmake/get_tcm.cmake https://github.com/TBlauwe/tcm/releases/download/0.3/get_tcm.cmake
  ```
  ```cmake
  set(TCM_DOWNLOAD_VERSION 0.4)
  include(cmake/get_tcm.cmake)
  ```
  
  *--or--*

  * `tcm.cmake` - to get file directly.
  ```bash
  wget -O cmake/tcm.cmake https://github.com/TBlauwe/tcm/releases/download/0.3/tcm.cmake
  ```
  ```cmake
  set(TCM_DOWNLOAD_VERSION 0.4)
  include(cmake/tcm.cmake)
  ```

## TODO

- [ ] Check user install and warn for missing tools
- [ ] Install
- [ ] Packing
- [ ] Bindings

## Credits

This project was inspired by __[FIPS](https://github.com/floooh/fips)__ and __[CPM](https://github.com/cpm-cmake/CPM.cmake)__.
