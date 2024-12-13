# TCM - CMake Modules


![CMake](https://img.shields.io/badge/CMake-%23008FBA.svg?style=for-the-badge&logo=cmake&logoColor=white)

Some standalone cmake modules used across my projects.

> [!NOTE]
>
> As most of my other repositories, they are mostly intended for personal usage and learning.
> You are probably better off looking elsewhere, like [awesome cmake](https://github.com/onqtam/awesome-cmake).


## Getting Started


__Automatic Installation__ _(with CPM)_ :

[CPM](https://github.com/cpm-cmake/CPM.cmake) is a CMake script to add dependency management to CMake.
To install it, see [CPM's documentation](https://github.com/cpm-cmake/CPM.cmake?tab=readme-ov-file#adding-cpm).
You can also use the provided script : `get_cpm.cmake`

Once CPM is installed, you can add the following in your `CMakeLists.txt`:

```cmake
CPMAddPackage(
        NAME tcm
        GITHUB_REPOSITORY tblauwe/cmake_modules
        GIT_TAG master
)
list(APPEND CMAKE_MODULE_PATH "${tcm_SOURCE_DIR}/cmake")

# Then, for any modules : 
include(tcm/<module_name>)

# Or if you want to include all modules
include(tcm/include_all)
```
__Manual Installation__ :

1. Download modules you are interested and add them to your project's files, e.g. inside a `cmake/` folder.
2. Include them in your cmake files
```cmake
include(cmake/<module>)
```


## Modules


Each module contains a quick documentation about its usage.

| Name                    | Description                                                                           |
|-------------------------|---------------------------------------------------------------------------------------|
| code_block              | Include source files in markdown code-blocks.                                         |
| get_cpm                 | Install [CPM](https://github.com/cpm-cmake/CPM.cmake).                                |
| prevent_in_source_build | As name says, this module prevents in source build.                                   |
| setup_cache             | Setup cache like ccache if available.                                                 |
| setup_version           | Deduce version either from git or from `VERSION.txt` when consumed.                   |
| support_computed_gotos  | Defines `${PROJECT_NAME}_SUPPORT_COMPUTED_GOTOS` if compiler supports them.           |
| utility.cmake           | Defines some utility functions : `target_assets`, some logging function, etc.         |
| warning_guard           | Defines `${PROJECT_NAME}_WARNING_GUARD` to prevent warnings when library is consumed. |


## Minimal CMake Example


```cmake
cmake_minimum_required(VERSION 3.21)
include(cmake/prevent_in_source_build.cmake)

project(YourProject)

include(cmake/get_cpm.cmake)
CPMAddPackage(
        NAME tcm
        GITHUB_REPOSITORY tblauwe/cmake_modules
        GIT_TAG master
)
list(APPEND CMAKE_MODULE_PATH "${tcm_SOURCE_DIR}/cmake")
include(tcm/include_all)
```

## Options

```cmake
# CPM
set(CPM_SOURCE_CACHE "~/.cpm/")  # You can also set it as an environment variable, so it works across projects.
set(CPM_DOWNLOAD_VERSION 0.40.2) # Default Value
set(CPM_HASH_SUM "c8cdc32c03816538ce22781ed72964dc864b2a34a310d3b7104812a5ca2d835d") #Default value

# TCM
set(TCM_VERBOSE TRUE) #False when project is consumed.
```
