# Module : Tools

__TCM__ ease the setup of some tools.

By default, the following are set up on include:
* __[CPM](https://github.com/cpm-cmake/CPM.cmake)__.
* __[CCache](https://ccache.dev/)__.

You can override this behaviour by setting `TCM_TOOLS`

>[!WARNING]
> If __[CPM](https://github.com/cpm-cmake/CPM.cmake)__ is not set up, most functionality will be disabled !
> (Unless, necessary libraries are already included, but you are on your own.)

## Usage 

```cmake
set(TCM_TOOLS "CPM;CCACHE")  # Install CPM and CCache (default)
include(cmake/tcm.cmake)
```
