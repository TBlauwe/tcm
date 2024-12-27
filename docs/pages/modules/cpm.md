# Module : CPM

This module provides a convenient way to install and setup __[CPM](https://github.com/cpm-cmake/CPM.cmake)__ with some preferences.

## Usage 

To install and setup __[CPM](https://github.com/cpm-cmake/CPM.cmake)__, call `tcm_setup_cpm()`.

```cmake
include(cmake/tcm.cmake)
tcm_setup()
# set(CPM_DOWNLOAD_VERSION ...) # If you wish to override default version.
tcm_setup_cpm()
```
