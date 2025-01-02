# Emscripten

__TCM__ provides a function to work with __[Emscripten](https://emscripten.org)__.


> [!tip]
>
> Make sure __[Emscripten](https://emscripten.org)__ is installed on your system and [check their toolchain file](https://github.com/emscripten-core/emscripten/blob/main/cmake/Modules/Platform/Emscripten.cmake).
> 
> You need to provide Emscripten's toolchain to CMake.
> One way is to pass `CMAKE_TOOLCHAIN_FILE "$env{EMROOT}/cmake/Modules/Platform/emscripten.cmake"`
> `EMROOT` is a variable environment (name may differ) set to the root of emscripten's install directory.

```cmake
tcm_target_setup_for_emscripten (
        <target>
        [SHELL_FILE <file>]
        [EMBED_DIR <dir>]
        [PRELOAD_DIR <dir>]
)
```
If `EMSCRIPTEN` is `ON` (it is, if using emscripten toolchain), then this target will produce:
* a `.html` file,
* a `.wasm` file,
* and a `.js` file,

If a `SHELL_FILE` is not provided, then the one embedded in __TCM__ will be used.
If `EMBED_DIR` is specified, then it will be embedded by emscripten.
If `PRELOAD_DIR` is specified, then it will be preloaded by emscripten.

A companion utility target, called `${target}_open_html` is also configured to run/open the produced html with `emrun`.
