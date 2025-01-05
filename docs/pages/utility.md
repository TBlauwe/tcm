# Utility

[TOC]

__TCM__ module provides standalone utility functions.

### tcm_target_copy_dll()

Copy files and folders to destination folder.

```cmake
tcm_target_copy_dll(<target> FROM <target_dependency>) #my_lib is a shared library
```

#### Example

Full example available here `tests/shared_static/CMakeLists.txt`.

```cmake
add_executable(test_shared main.cpp)
target_link_libraries(test_shared PRIVATE my_lib)
tcm_target_copy_dll(test_shared FROM my_lib) #my_lib is a shared library
```

--------------------------------------------------------------------------------

### tcm_target_options()

Add homonym compile define if option is ON. 

```cmake
tcm_target_options (
        <target>
        <OPTIONS> [options...]
)
```
#### Example

Full example available here `tests/utility/CMakeLists.txt`.

```cmake
option(OPTION_A "A test option" ON)
option(OPTION_B "A test option" OFF)
option(OPTION_C "A test option" ON)

add_executable(test_utility main.cpp)

tcm_target_options(test_utility OPTIONS OPTION_A OPTION_B OPTION_C)
#-DOPTION_A -DOPTION_C are added to compile definitions.
```

--------------------------------------------------------------------------------

### tcm_target_copy_assets()

Copy files and folders to destination a folder relative to target runtime output dir.

```cmake
tcm_target_copy_assets (
        <target> 
        [OUTPUT_DIR <dir>           # Default to assets/
        [FILES <file_or_dir>... ]   # Files to copy 
)
```

`OUTPUT_DIR` must be a relative path. 

#### Example

Full example available here `tests/utility/CMakeLists.txt`.

```cmake
# root/
#   CMakeLists.txt
#   copy_me_2.txt
#   copy_me_3.txt
#   assets/copy_me.txt
#   assets/copy_me_1.txt
#   assets/sub/copy_me.txt
#   assets/sub/copy_me_1.txt
#   assets/sub_1/copy_me.txt
#   assets/sub_1/copy_me_1.txt

tcm_target_copy_assets(test_utility
        FILES copy_me_2.txt copy_me_3.txt assets/sub assets/sub_1 assets 
        # Could be only assets (here only for demonstration)
)
```

--------------------------------------------------------------------------------

### tcm_target_enable_optimisation_flags()

Enable optimisation flags for target (speed for desktop, size for web) for RELEASE builds.

```cmake
tcm_target_enable_optimisation_flags (<target>)
```

--------------------------------------------------------------------------------

### tcm_target_enable_warning_flags()

Enable warnings flags for target.

```cmake
tcm_target_enable_warning_flags (<target>)
```

--------------------------------------------------------------------------------
