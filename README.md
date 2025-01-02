# TCM - A CMake Module

![CMake](https://img.shields.io/badge/CMake%20%3E%3D%203.26-%23008FBA.svg?style=for-the-badge&logo=cmake&logoColor=white)

__TCM__ is a CMake module to reduce boilerplate and ease setup of some functionalities.

* Set project's version from Git or from generated `VERSION` file when consumed.
* Setup documentation with __[Doxygen](https://www.doxygen.nl/)__ (if installed) and __[Doxygen Awesome](https://github.com/jothepro/doxygen-awesome-css)__.
* Setup various tools:
  * __[ccache](https://ccache.dev/)__.
  * __[CPM](https://github.com/cpm-cmake/CPM.cmake)__.
* Enable common settings for targets (warnings, options, emscripten support, etc.) depending on the build configuration.
* Quickly add tests with __[Catch2](https://github.com/catchorg/Catch2)__.
* Quickly add benchmarks with __[Google Benchmarks](https://github.com/google/benchmark)__.
* Configure examples with automated test and benchmarks.
* and some other handy functions.

See [documentation](https://tblauwe.github.io/tcm/) for a closer look.

> [!NOTE]
>
> TCM is opinionated.
> Defaults should give you good enough results.
> Most functions are customizable, but only to some extent.
> If you need full control, you are better off writing your own scripts.


## Main Features

* __Easy to distribute / deploy__ 
  * Inspired by __[STB](https://github.com/nothings/stb)__, __TCM__ is packed into a single CMake script.
  * Public domain licence.
  * Files required for some functionalities are embedded in the script:
    * emscripten's default shell,
    * documentation's default header, footer, css and doxygen layout.
* __Only use what you need__
  * No function is imposed
  * No variable or parameters are modified without the explicit use of some functionalities.
    * In that case, documentation should be clear as to what changed.
* __Modern CMake__
  * A great care is given to write clean & robust cmake script, using resources like :
    * [cmake-init](https://github.com/friendlyanon/cmake-init)
    * [CLI Utils - Modern CMake](https://cliutils.gitlab.io/modern-cmake/README.html)
    * [Craig Scott resources](https://crascit.com/2019/10/16/cppcon-2019-deep-cmake-for-library-authors/)
    * [FIPS](https://github.com/floooh/fips)
    * [CPM](https://github.com/cpm-cmake/CPM.cmake)
    * and also many open-source projects.
* __Composition over Inheritance approach__
  * You cannot easily "inherit" from multiple templates or generators.
    Also, overtime, template will update, fix bugs, bring new functionalities and so on.
    There are ways to sync changes, but there are still some friction, notably with generated code.
    With CMake modules, you can easily combine them and use them with a template.
* __De-cluttered logs__
  * On subsequent runs, changes from previous run are prefixed by `(!)` (blue-colored if possible).

| Before | After modifying some examples |
| --- | --- |
| ![log_before.png](assets/log_before.png)| ![log_after.png](assets/log_after.png)|
 
> [!NOTE]
> __There is no "TCM over cmake-init" or any other templates, modules, etc.__
> You can perfectly start a project with __[cmake-init](https://github.com/friendlyanon/cmake-init)__ and use some functionalities provided by __TCM__.
> __TCM__ is an opinionated CMake module. Use functionalities you like and discard others without cluttering your code.


## Getting Started

> [!WARNING]
>
> Under construction / Needs testing.

Same instructions as for any single file (e.g. [CPM's documentation](https://github.com/cpm-cmake/CPM.cmake?tab=readme-ov-file#adding-cpm)).
You can either:

* download or copy `get_tcm.cmake`, a script to easily download and update `tcm.cmake` through cmake.
 
```cmake
set(TCM_DOWNLOAD_VERSION 0.5.0)
include(cmake/get_tcm.cmake)
```

* or download `tcm.cmake` directly

```cmake
include(cmake/tcm.cmake)
```

These two files are also available at these URLS :

```
wget -O cmake/tcm.cmake https://github.com/TBlauwe/tcm/releases/download/0.5.0/tcm.cmake
wget -O cmake/get_tcm.cmake https://github.com/TBlauwe/tcm/releases/download/0.5.0/get_tcm.cmake
```


## TODO

- [ ] Check if in some places, properties/var should be added to a target. are better suited 
- [ ] Check user install and warn for missing tools
- [ ] Install
- [ ] Packing
- [ ] Bindings
- [ ] Emscripten / add shader compiler
- [ ] Maybe propose a single function to parametrize target according to current settings (optimization, warnings, emscripten)
- [ ] Add automated credits / header for readme ?
- [ ] Setup version from project rather than git (way less friction).
- [ ] Improve UX
  - Add warning for incorrect usage (required parameters, etc.)
  - Normalize as much as possible (e.g. handle files and folders like for tcm_target_copy_assets)


## Credits

This project was inspired by __[STB](https://github.com/nothings/stb)__, __[FIPS](https://github.com/floooh/fips)__ and __[CPM](https://github.com/cpm-cmake/CPM.cmake)__.
