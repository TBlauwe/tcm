# Module : Utility functions

This module provides some useful variables.
Credits : __[FIPS](https://github.com/floooh/fips)__

## Setup

No setup.


## Side-effects

Following variables are set :

| Name                         | Description                                                                                                                                                          |
|------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| TCM_EXE_DIR                  | Default : `${PROJECT_BINARY_DIR}/bin`. A convenience variable to store executables in a bin/ folder.                                                                 |
| TCM_HOST_WINDOWS             | `1` if host is a Windows machine, `0` otherwise.                                                                                                                     |
| TCM_HOST_OSX                 | `1` if host is an Apple machine, `0` otherwise.                                                                                                                      |
| TCM_HOST_LINUX               | `1` if host is an Unix machine or an unrecognized one, `0` otherwise.                                                                                                |
| TCM_CLANG                    | `1` if compiler is Clang, `0` otherwise.                                                                                                                             |
| TCM_APPLE_CLANG              | `1` if compiler is Apple's Clang variant, `0` otherwise.                                                                                                             |
| TCM_CLANG_CL                 | `1` if compiler is Microsoft's Clang-cl variant, `0` otherwise.                                                                                                      |
| TCM_GCC                      | `1` if compiler is GNU, `0` otherwise.                                                                                                                               |
| TCM_INTEL                    | `1` if compiler is INTEL, `0` otherwise.                                                                                                                             |
| TCM_SUPPORTED_COMPUTED_GOTOS | `1` if compiler support computed gotos (by compiling a test file).                                                                                                   |
| TCM_WARNING_GUARD            | Empty if project is top-level, "SYSTEM" otherwise. Useful to prevent warnings from include directories. |

