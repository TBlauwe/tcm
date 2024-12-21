# Development

__TCM__ is packed into a single CMake script called : `tcm.cmake`.
This file is configured by `src/CMakeLists.txt` from the various modules `*.cmake` in this folder.

Some other files are also embedded like:
* `docs/header.html`, 
* `docs/footer.html`, 
* `docs/DoxygenLayout.xml`, 
* `docs/custom.css` 
* `assets/shell_minimal.html` 
 

## Guidelines

Here are some guidelines I try to follow for this codebase.
Some are not standard and just a matter of preferences.
Overall, I prefer the explicit over the implicit.


### Naming

* Public functions are prefixed by `tcm_` and use `tcm_snake_case()`.
* Private functions are prefixed by `tcm__` (double underscore) and use `tcm_snake_case()`.
* Variables use `CAMEL_CASE`, except local variables.
    * To prevent clash with cache and parent variables (unless desired) :
      * arguments are prefixed by `arg_`.
      * local variables use `snake_case`.
* Options are prefixed by `TCM_`
* _[There are other considerations when using macros](https://cmake.org/cmake/help/latest/command/cmake_parse_arguments.html)_.
  * e.g. if using `cmake_parse_arguments` don't prefix by `arg_` but by `arg_macro_name_`.


### Module

* Each module should not be dependent of the usage of another module.
  * It is fine to call a function from another module, especially Logging.
  * But it is not to hide "dependencies" from some function calls in other modules.
* When relevant, most module should provide a default target prefixed by `TCM_`, e.g. `TCM_TESTS`, `TCM_DOCS`, etc.
* Each module setup function should consider that it could be included more than once (from subprojects).


### Functions

* Macros are fine if every change should happen in parent scope. But don't pollute it (e.g. with local variables) !
* Otherwise, prefer functions to macros.
  * To share settings, attach properties to `TCM`
* Functions should work over a target (or default one)
* Favours explicit parameters rather than implicit, i.e. named arguments.
  * It is fine to add `TARGET` than just assuming that the first argument should be a target.
  * __except__ for single argument function (with possible options).


### Targets

* __TCM__ creates a homonym utility target `TCM` to store and share settings used throughout TCM.


## Tests

__TCM__ is tested through CMake by various means but there is still much to improve.
Tests are located in subfolders inside `tcm/tests`.
Each test usually create a new CMake project.
Where possible, tests use CTest, but some functionalities are hard to automate (like logging).
