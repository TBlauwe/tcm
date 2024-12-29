# Development

__TCM__ is packed into a single CMake script called : `cmake/tcm.cmake`.
This file is configured from the various modules `*.cmake` in this folder.

Some other files are also embedded like:
* `docs/header.html`, 
* `docs/footer.html`, 
* `docs/DoxygenLayout.xml`, 
* `docs/custom.css` 
* `assets/shell_minimal.html` 
 

## Guidelines

Here are some guidelines I try to follow for this codebase.
Some are not standard and just a matter of preferences.


### User experience

Overall, __TCM__ strives for simplicity while keeping side effects to a minimum.

* Default should be good enough.
* Allow composition and customization, when possible.
* Favor opt-in mentality; don't impose something to the user.
* Keep performance impact low
  * Cache heavy operations, like `try_compile`.
* Don't alter already defined CMake behaviour/variables
  * Most variables' setting should be guarded by `if(NOT DEFINED ...)`
* Use target.


### Naming

* Functions/Macros use `tcm_snake_case()`.
  * Public functions are prefixed by `tcm_`.
  * Private functions are prefixed by `tcm__` (double underscore). 
* Variables use `CAMEL_CASE`, except:
  * local variables use `snake_case`.
  * arguments are prefixed by `arg_`.
* Options are prefixed by `TCM_`

_[There are other considerations when using macros](https://cmake.org/cmake/help/latest/command/cmake_parse_arguments.html)_,
e.g. if using `cmake_parse_arguments` don't prefix by `arg_` but by `arg_macro_name_`.


### CMake

* Reduce scope pollution to a minimum
  * -> Prefer functions to macros
  * -> Prefer arguments to variables when pertinent.
* Macros are fine if every change should happen in parent scope.
  * /!\ But don't pollute it (e.g. with local variables) !
* Favors named arguments


### Module

* Each module should not be dependent of the usage of another module.
  * It is fine to call a function from another module, especially Logging.
  * But it is not to hide "dependencies" from some function calls in other modules.
* When relevant, most module should provide a default target prefixed by `TCM_`, e.g. `TCM_TESTS`, `TCM_DOCS`, etc.
* Each module setup function should consider that it could be included more than once (from subprojects).
 

## Logging

I like having nice, concise and readable cmake output. 
But sometimes I get carried away and spam with too much information.
Ideally, I think that a cmake output should only inform me of things that have changed since last run.
I don't care to see for the n-th times that I'm using this tool with this version, etc.
It is fine for a first run without cache, but afterward I don't want to see this kind of information.

So now I try to follow these guidelines:

* A consumed project should the strict minimum, if nothing, at the default level, unless there is a problem
* Prefer `tcm_info` for changes for this run !
  * Sometimes, some results / modifications like files generation are cached. 
    An info message is displayed only the first time they are built.
* If nothing out of the ordinary happened, don't say anything (especially empty sections / check sections).
* It is fine to see what is configured, but only if it is the top project.


## Tests

__TCM__ is tested through CMake by various means but there is still much to improve.
Tests are located in subfolders inside `tcm/tests`.
Each test usually create a new CMake project.
Where possible, tests use CTest, but some functionalities are hard to automate (like logging).
