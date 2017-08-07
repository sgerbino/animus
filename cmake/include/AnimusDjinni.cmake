macro(animus_setup_djinni_command)
   set(DJINNI_COMMAND ${DJINNI_EXECUTABLE}
      --cpp-out ${ANIMUS_INTERFACE_DIR}
      --java-out ${ANIMUS_JAVA_DIR}
      --jni-out ${ANIMUS_JNI_DIR}
      --objc-out ${ANIMUS_OBJC_DIR}
      --objcpp-out ${ANIMUS_OBJC_DIR}
      --objcpp-include-cpp-prefix interface/
      --jni-include-cpp-prefix interface/
      --cpp-optional-header "\"<experimental/optional>\""
      --cpp-optional-template std::experimental::optional
      --cpp-namespace ${ANIMUS_CPP_NAMESPACE}
      --java-package ${ANIMUS_JAVA_PACKAGE}
      --jni-namespace ${ANIMUS_JNI_NAMESPACE}
#      --objc-type-prefix "${ANIMUS_OBJC_TYPE_PREFIX}"
      --objcpp-namespace ${ANIMUS_OBJCPP_NAMESPACE}
      --ident-cpp-enum ${ANIMUS_IDENT_CPP_ENUM}
      --ident-cpp-field ${ANIMUS_IDENT_CPP_FIELD}
      --ident-cpp-method ${ANIMUS_IDENT_CPP_METHOD}
      --ident-cpp-enum-type ${ANIMUS_IDENT_CPP_ENUM_TYPE}
      --ident-cpp-type-param ${ANIMUS_IDENT_CPP_TYPE_PARAM}
      --ident-cpp-local ${ANIMUS_IDENT_CPP_LOCAL}
      --ident-cpp-file ${ANIMUS_IDENT_CPP_FILE}
      --ident-cpp-type ${ANIMUS_IDENT_CPP_TYPE}
      --ident-java-field ${ANIMUS_IDENT_JAVA_FIELD}
      --ident-jni-class ${ANIMUS_IDENT_JNI_CLASS}
      --ident-jni-file ${ANIMUS_IDENT_JNI_FILE}
      --idl ${ANIMUS_INTERFACE_DEFINITION})
endmacro()

macro(animus_add_djinni_targets)
   list(APPEND DJINNI_OUTPUT_FILES ${DJINNI_JNI_FILES} ${DJINNI_OBCJ_FILES} ${DJINNI_JAVA_FILES} ${DJINNI_INTERFACE_FILES})

   add_custom_command(
      OUTPUT ${DJINNI_GENERATED_FILES}
      COMMAND ${DJINNI_COMMAND}
      WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}
      DEPENDS ${ANIMUS_INTERFACE_DEFINITION})

   add_custom_target(djinni
      DEPENDS ${DJINNI_OUTPUT_FILES}
      SOURCES
         ${ANIMUS_INTERFACE_DEFINITION}
         ${ANIMUS_DJINNI_DIR}/thread_launcher.djinni
         ${ANIMUS_DJINNI_DIR}/event_loop.djinni
         ${ANIMUS_DJINNI_DIR}/http.djinni)
endmacro()

macro(animus_get_djinni_output_files)
   execute_process(COMMAND ${DJINNI_COMMAND} --skip-generation true --list-out-files djinni.out OUTPUT_QUIET)

   file(STRINGS ${PROJECT_BINARY_DIR}/djinni.out DJINNI_GENERATED_FILES)
   message("-- Djinni will generate the following files: ")
   foreach(ITEM ${DJINNI_GENERATED_FILES})
      message("--  `-> ${ITEM}")
      get_filename_component(ITEM_DIRECTORY ${ITEM} DIRECTORY)
      get_filename_component(ITEM_NAME ${ITEM} NAME)
      if (${ITEM_DIRECTORY} STREQUAL ${ANIMUS_JNI_DIR})
         list(APPEND DJINNI_JNI_FILES ${ITEM_DIRECTORY}/${ITEM_NAME})
      endif()
      if (${ITEM_DIRECTORY} STREQUAL ${ANIMUS_OBJC_DIR})
         list(APPEND DJINNI_OBJC_FILES ${ITEM_DIRECTORY}/${ITEM_NAME})
         if (${ITEM_NAME} MATCHES "\\.h$" AND NOT ${ITEM_NAME} MATCHES "\\+Private\\.h$")
            list(APPEND DJINNI_OBJC_HEADER_FILES ${ITEM_NAME})
            list(APPEND DJINNI_OBJC_HEADER_FILES_WITH_PATH ${ITEM_DIRECTORY}/${ITEM_NAME})
         endif()
      endif()
      if (${ITEM_DIRECTORY} STREQUAL ${ANIMUS_JAVA_DIR})
         list(APPEND DJINNI_JAVA_FILES ${ITEM_DIRECTORY}/${ITEM_NAME})
      endif()
      if (${ITEM_DIRECTORY} STREQUAL ${ANIMUS_INTERFACE_DIR})
         list(APPEND DJINNI_INTERFACE_FILES ${ITEM_DIRECTORY}/${ITEM_NAME})
      endif()
   endforeach()
endmacro()
