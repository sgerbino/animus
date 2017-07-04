add_executable(${ANIMUS_BINARY_NAME}-test main.cpp)
target_link_libraries(${ANIMUS_BINARY_NAME}-test ${ANIMUS_BINARY_NAME})
target_include_directories(${ANIMUS_BINARY_NAME}-test PUBLIC {ANIMUS_INTERFACE_DIR})
