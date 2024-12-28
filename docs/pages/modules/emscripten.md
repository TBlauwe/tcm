# Module : Emscripten

This module provides functions to work with __[Emscripten](https://emscripten.org)__.

```cmake
tcm_target_setup_for_emscripten (
        [TARGET] <target>
        [SHELL_FILE <file>]
        [ASSETS_DIR <dir>]
)
```
If `EMSCRIPTEN` is `ON` (it is, if using emscripten toolchain), then this target will produce:
* a `.html` file,
* a `.wasm` file,
* and a `.js` file,

If a `SHELL_FILE` is not provided, then the one embedded in __TCM__ will be used.
If an `ASSETS_DIR` is specified, then it will be preloaded by emscripten.

A companion utility target, called `${target}_open_html` is also configured to run/open the produced html with `emrun`.
