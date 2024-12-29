# Module : Documentation

This module provides a single function to generate a documentation using __[Doxygen](https://www.doxygen.nl/)__ (if installed) and __[Doxygen Awesome](https://github.com/jothepro/doxygen-awesome-css)__.

```cmake
tcm_setup_docs (
        [DOXYGEN_AWESOME_VERSION "vX.X.X"]
)
```
It uses `doxygen_add_docs()` under the hood.
So, any Doxygen config option can be overridden by setting relevant variables before calling `tcm_setup_docs()`.
For more information : https://cmake.org/cmake/help/latest/module/FindDoxygen.html

However, following parameters cannot not be overridden, since `tcm_setup_docs()` is setting them:
* `DOXYGEN_GENERATE_TREEVIEW` to `YES`
* `DOXYGEN_DISABLE_INDEX` to `NO`
* `DOXYGEN_FULL_SIDEBAR` to `NO`
* `DOXYGEN_HTML_COLORSTYLE`	to `LIGHT`
* `DOXYGEN_DOT_IMAGE_FORMAT` to `svg`

By default, `DOXYGEN_USE_MDFILE_AS_MAINPAGE` is set to `"${PROJECT_SOURCE_DIR}/README.md"`.

Also, TCM provides a default header, footer, stylesheet, extra files (js script).
You can override them, but since they are tightly linked together, you are better off not calling tcm_setup_docs().
