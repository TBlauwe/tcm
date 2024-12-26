# Module : Utility functions

This module provides some miscellaneous / utility functions.

## Setup

No setup.


## Side-effects

No side effects 


## API

### tcm_target_options()

Add homonym compile define if option is ON. 

```cmake
tcm_target_options ([TARGET] <target>
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

Copy files and folders to destination folder.

```cmake
tcm_target_copy_assets (
        arg_TARGET
        [OUTPUT_DIR ...]    # Default to $<TARGET_FILE_DIR:${arg_TARGET}>/assets
        [FILES ... ]        # Files to copy 
        [FOLDERS ]          # Directories to copy
)
```
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
        FILES copy_me_2.txt copy_me_3.txt 
        FOLDERS assets/sub assets/sub_1 assets # Could be only assets (here only for demonstration)
)
```


--------------------------------------------------------------------------------