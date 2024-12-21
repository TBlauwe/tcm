# Module : Utility functions

This module provides some miscellaneous / utility functions.

## Setup

No setup.


## Side-effects

No side effects 


## API

```cmake
tcm_suppress_warnings(arg_TARGET)
```
Should suppress warnings emitted from `arg_target`, by adding `SYSTEM` modifier to its include directories.

> [!WARNING]
>
> Doesn't seem to always works.


------------------------------------------------------------------------------------------------------------------------
```cmake
tcm_option_define(_target _option)
```
Define `-D${_option}` for `_target` when `_option` is ON.


------------------------------------------------------------------------------------------------------------------------
```cmake
tcm_target_assets(_target _src_dir _dst_dir)
```
Copy folder `_src_dir` to `_dst_dir` before target is built.


------------------------------------------------------------------------------------------------------------------------
```cmake
tcm_generate_export_header(_target)
```

A wrapper over `generate_export_header` with some preferred default, properties set (VERSION, SOVERSION, etc.), and export directory already included.
