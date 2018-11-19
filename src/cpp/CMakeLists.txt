source_group("Interface Files" FILES ${DJINNI_INTERFACE_FILES})
set_source_files_properties(${DJINNI_INTERFACE_FILES} PROPERTIES GENERATED TRUE)

add_library(${LIBRARY_NAME} ${CPP_HEADERS} ${CPP_SOURCES} ${DJINNI_INTERFACE_FILES})
add_dependencies(${LIBRARY_NAME} djinni)
target_include_directories(${LIBRARY_NAME} PUBLIC ${GEN_DIR} ${INTERFACE_DIR} ${PROJECT_SOURCE_DIR}/${DEPS_DIR}/json/include)
target_compile_definitions(${LIBRARY_NAME} PRIVATE -DPROJECT_NAME=${PROJECT_NAME} -DPROJECT_VERSION="${PROJECT_VERSION}")
