set(PROJECT_JNI_LIBRARY ${PROJECT_NAME}-jni)

foreach(ITEM ${DJINNI_GENERATED_FILES})
   get_filename_component(ITEM_DIRECTORY ${ITEM} DIRECTORY)
   get_filename_component(ITEM_NAME ${ITEM} NAME)
   if (${ITEM_DIRECTORY} STREQUAL ${PROJECT_JNI_DIR})
      list(APPEND DJINNI_JNI_FILES ${ITEM_NAME})
   endif()
endforeach()

add_library(${PROJECT_JNI_LIBRARY} ${DJINNI_JNI_FILES})
target_include_directories(${PROJECT_JNI_LIBRARY} PUBLIC ${PROJECT_SOURCE_DIR}/${PROJECT_GEN_DIR})
add_dependencies(${PROJECT_JNI_LIBRARY} ${PROJECT_NAME} djinni_support_lib)
