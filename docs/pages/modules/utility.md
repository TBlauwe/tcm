# Module : Utility functions

This module provides some miscellaneous / utility functions.

## Setup

No setup.


## Side-effects

No side effects 


## API

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