cmake_minimum_required(VERSION 3.25)

execute_process(
        COMMAND ${CMAKE_COMMAND} -E compare_files --ignore-eol "${SOURCE_DIR}/assets/copy_me.txt" "${DEST_DIR}/assets/copy_me.txt"
        COMMAND ${CMAKE_COMMAND} -E compare_files --ignore-eol "${SOURCE_DIR}/assets/copy_me_1.txt" "${DEST_DIR}/assets/copy_me_1.txt"
        COMMAND ${CMAKE_COMMAND} -E compare_files --ignore-eol "${SOURCE_DIR}/copy_me_2.txt" "${DEST_DIR}/assets/copy_me_2.txt"
        COMMAND ${CMAKE_COMMAND} -E compare_files --ignore-eol "${SOURCE_DIR}/copy_me_3.txt" "${DEST_DIR}/assets/copy_me_3.txt"
        COMMAND ${CMAKE_COMMAND} -E compare_files --ignore-eol "${SOURCE_DIR}/assets/sub/copy_me.txt" "${DEST_DIR}/assets/sub/copy_me.txt"
        COMMAND ${CMAKE_COMMAND} -E compare_files --ignore-eol "${SOURCE_DIR}/assets/sub/copy_me_1.txt" "${DEST_DIR}/assets/sub/copy_me_1.txt"
        COMMAND ${CMAKE_COMMAND} -E compare_files --ignore-eol "${SOURCE_DIR}/assets/sub_1/copy_me.txt" "${DEST_DIR}/assets/sub_1/copy_me.txt"
        COMMAND ${CMAKE_COMMAND} -E compare_files --ignore-eol "${SOURCE_DIR}/assets/sub_1/copy_me_1.txt" "${DEST_DIR}/assets/sub_1/copy_me_1.txt"
        RESULTS_VARIABLE RESULTS
        COMMAND_ECHO STDOUT
)


if("1" IN_LIST RESULTS)
    message(FATAL_ERROR "One of the files comparison failed : ${RESULTS}")
else ()
    message(STATUS "All files correctly copied : ${RESULTS}")
endif ()
