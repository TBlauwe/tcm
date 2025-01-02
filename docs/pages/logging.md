# Logging

__TCM__ provides some logging functions.
Following variables will alter its behaviours:

```cmake
set(TCM_VERBOSE ON) # Toggleable verbosity
set(CMAKE_COLOR_DIAGNOSTICS  OFF) # Disable colors
```

> [!note]
> 
> Tools like IDE should normally set `CMAKE_COLOR_DIAGNOSTICS` automatically.
 
During setup:

* If `CMAKE_MESSAGE_CONTEXT_SHOW` is not already set by the user, it defaults to `TRUE`.
* If `CMAKE_MESSAGE_CONTEXT` is not already set by the user, it defaults to `${PROJECT_NAME}`.
 
__TCM__ provides two handy functions to manipulate `CMAKE_MESSAGE_CONTEXT` :
* `tcm_section("...")` - append a name to `CMAKE_MESSAGE_CONTEXT`.
* `tcm_section_end()` - pop last element from `CMAKE_MESSAGE_CONTEXT`.

Most of the time, you don't have to close a section, unless you want to open and close them in the same scope.
CMake's scoping rules take care of this.


## API

```cmake 
#tcm_fatal_error("Error message")
tcm_error("Expected error message.")
tcm_warn("Expected warning message.")
#tcm_author_warn("Expected author warning message.")
tcm_info("An info message.")
tcm_log("A normal message.")
tcm_debug("YOU SHOULD NOT SEE THIS.")
tcm_trace("YOU SHOULD NOT SEE THIS.")
tcm_check_start("Start a section")
    tcm_check_start("Should ...")
    tcm_check_fail("fail.")
tcm_check_pass("done.")

tcm_section("SECTION")
    tcm_info("An info message.")
    tcm_section("TRACE_LEVEL")
        set(CMAKE_MESSAGE_LOG_LEVEL TRACE)
        tcm_log("Setting CMAKE_MESSAGE_LOG_LEVEL to TRACE")
        tcm_debug("A debug message.")
        tcm_trace("A trace message.")
#    tcm_section_end() #OPTIONAL - Scoping rule will take care of this.
# tcm_section_end() # OPTIONAL - Scoping rule will take care of this.
```
![sample_documentation.png](assets/sample_documentation.png)

You can also use `tcm_indent()` and `tcm_outdent()` for indenting/outdenting messages.
