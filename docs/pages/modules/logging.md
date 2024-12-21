# Module : Logging

## Setup

This module is automatically setup on `tcm.cmake` inclusion.

Available options :

```cmake
set(TCM_VERBOSE ON) # Toggleable verbosity
```

## Side-effects

During setup:

* If `CMAKE_MESSAGE_CONTEXT_SHOW` is not already set by the user, it defaults to `TRUE`.
* If `CMAKE_MESSAGE_CONTEXT` is not already set by the user, it defaults to `${PROJECT_NAME}`.

__TCM__ provides two handy functions to manipulate `CMAKE_MESSAGE_CONTEXT` :
* `tcm_section("...")` - append a name to `CMAKE_MESSAGE_CONTEXT`.
* `tcm_section_end()` - pop last element from `CMAKE_MESSAGE_CONTEXT`.

This module plays nicely with `CMAKE_MESSAGE_CONTEXT` and respect scoping rules. 
Most of the time, you don't have to close a section, unless you want to open and close them in the same scope.


## API

```cmake 
tcm_error("Abort message." FATAL)     # A FATAL_ERROR message under the hood. 
tcm_error("Expected error message.")  # A STATUS message under the hood.
tcm_warn("Expected warning message.") # A STATUS message under the hood or as AUTHOR_WARNING by adding AUTHOR_WARNING .
tcm_info("An info information.")      # A STATUS message under the hood.
tcm_log("A normal message.")          # A STATUS message under the hood.

set(CMAKE_MESSAGE_LOG_LEVEL TRACE)    # To enable lower-level message.
tcm_debug("A debug message.")
tcm_trace("A trace message.")

# Nestable sections
tcm_section("SECTION")
    tcm_log("A normal message in a section.")
    
    tcm_section("SUBSECTION")
        tcm_log("A normal message in a subsection.")
    # tcm_section_end() # OPTIONAL - Scoping rules take care of this.
# tcm_section_end() # OPTIONAL - Scoping rules take care of this.
```

Some additional functions:
* `tcm_check_start(), tcm_check_pass(), tcm_check_fail()` for check section.
* `tcm_indent(), tcm_outdent()` for indenting/outdenting messages.
