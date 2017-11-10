macro(animus_add_jni)
   if (${ANIMUS_WITH_JNI})
      set(ANIMUS_JNI_LIBRARY ${ANIMUS_BINARY_NAME}-jni)
      add_library(${ANIMUS_JNI_LIBRARY} SHARED ${DJINNI_JNI_FILES})
      target_include_directories(${ANIMUS_JNI_LIBRARY} PUBLIC ${ANIMUS_GEN_DIR} ${JNI_INCLUDE_DIRS} ${DJINNI_JNI_INCLUDE_DIR})
      target_link_libraries(${ANIMUS_JNI_LIBRARY} ${ANIMUS_BINARY_NAME} djinni_support_lib)
      set_target_properties(${ANIMUS_JNI_LIBRARY} PROPERTIES PROJECT_LABEL "JNI")

      install(TARGETS ${ANIMUS_JNI_LIBRARY}
           RUNTIME DESTINATION bin
           LIBRARY DESTINATION lib
           ARCHIVE DESTINATION lib/static
           FRAMEWORK DESTINATION Frameworks)
   endif()
endmacro()
