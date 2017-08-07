source_group("Interface Files" FILES ${DJINNI_INTERFACE_FILES})
set_source_files_properties(${DJINNI_INTERFACE_FILES} PROPERTIES GENERATED TRUE)

add_library(${ANIMUS_BINARY_NAME} api.cpp api.hpp task_runner.hpp http.hpp http.cpp event_loop.hpp event_loop.cpp ${DJINNI_INTERFACE_FILES})
add_dependencies(${ANIMUS_BINARY_NAME} djinni)
target_include_directories(${ANIMUS_BINARY_NAME} PUBLIC ${ANIMUS_GEN_DIR} ${ANIMUS_INTERFACE_DIR} ${JSON_INCLUDE_DIRS})
