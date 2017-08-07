macro(animus_add_objc)
   if (${ANIMUS_WITH_OBJC})
      set(ANIMUS_OBJC_IMPLEMENTATION_FILES
         ${ANIMUS_OBJC_SRC_DIR}/AppleEventLoop.h
         ${ANIMUS_OBJC_SRC_DIR}/AppleEventLoop.m
         ${ANIMUS_OBJC_SRC_DIR}/AppleHttp.h
         ${ANIMUS_OBJC_SRC_DIR}/AppleHttp.m
         ${ANIMUS_OBJC_SRC_DIR}/AppleThreadLauncher.h
         ${ANIMUS_OBJC_SRC_DIR}/AppleThreadLauncher.m)

      set(ANIMUS_OBJC_LIBRARY ${ANIMUS_BINARY_NAME}-objc)
      list(APPEND ANIMUS_OBJC_FILES ${ANIMUS_OBJC_UMBRELLA_HEADER} ${DJINNI_OBJC_FILES})
      set_source_files_properties(${ANIMUS_OBJC_FILES} PROPERTIES GENERATED TRUE)
      add_library(${ANIMUS_OBJC_LIBRARY} SHARED ${ANIMUS_OBJC_FILES} ${ANIMUS_OBJC_IMPLEMENTATION_FILES})
      target_include_directories(${ANIMUS_OBJC_LIBRARY} PUBLIC ${ANIMUS_GEN_DIR}/objc)
      target_link_libraries(${ANIMUS_OBJC_LIBRARY} ${ANIMUS_BINARY_NAME} djinni_support_lib)
      list(APPEND
         DJINNI_OBJC_HEADER_FILES_WITH_PATH
            ${ANIMUS_OBJC_DIR}/${ANIMUS_PROJECT_NAME}.h
            ${ANIMUS_OBJC_SRC_DIR}/AppleEventLoop.h
            ${ANIMUS_OBJC_SRC_DIR}/AppleHttp.h
            ${ANIMUS_OBJC_SRC_DIR}/AppleThreadLauncher.h)
      set_target_properties(${ANIMUS_OBJC_LIBRARY} PROPERTIES
         FRAMEWORK TRUE
         FRAMEWORK_VERSION A
         MACOSX_FRAMEWORK_IDENTIFIER ${ANIMUS_PROJECT_IDENTIFIER}
         VERSION ${PROJECT_VERSION}
         SOVERSION ${PROJECT_VERSION}
         PUBLIC_HEADER "${DJINNI_OBJC_HEADER_FILES_WITH_PATH}"
         XCODE_ATTRIBUTE_CODE_SIGN_IDENTITY ""
         XCODE_ATTRIBUTE_CODE_SIGN_REQUIRED NO
         XCODE_ATTRIBUTE_CLANG_ENABLE_OBJC_ARC YES
         PROJECT_LABEL "Djinni Objective-C/C++"
         OUTPUT_NAME ${ANIMUS_PROJECT_NAME})
   endif()
endmacro()

macro(animus_generate_objc_umbrella_header)
   message("-- Generating Objective-C umbrella header (${ANIMUS_OBJC_UMBRELLA_HEADER})")
   file(REMOVE ${ANIMUS_OBJC_UMBRELLA_HEADER})
   list(APPEND
      DJINNI_OBJC_HEADER_FILES
         AppleEventLoop.h
         AppleHttp.h
         AppleThreadLauncher.h)
   foreach(ITEM IN LISTS DJINNI_OBJC_HEADER_FILES)
      message("--  `-> Including ${ITEM}")
      file(APPEND ${ANIMUS_OBJC_UMBRELLA_HEADER} "#import \"${ITEM}\"\n")
   endforeach()
endmacro()
