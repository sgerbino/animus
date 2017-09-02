find_program(BASH_EXECUTABLE bash)
find_program(GIT_EXECUTABLE git)

function(execute_process_with_activity)
   set(options )
   set(oneValueArgs MESSAGE COMMAND WORKING_DIRECTORY)
   set(multiValueArgs  )
   cmake_parse_arguments(ACTIVITY "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

   if (NOT ACTIVITY_MESSAGE)
      message(FATAL_ERROR "A message must be provided to execute_process_with_activity()")
   endif()
   if (NOT ACTIVITY_COMMAND)
      message(FATAL_ERROR "A command must be provided to execute_process_with_activity()")
   endif()
   if (NOT ACTIVITY_WORKING_DIRECTORY)
      message(FATAL_ERROR "A working directory must be provided to execute_process_with_activity()")
   endif()

   list(APPEND ACTIVITY_FULL_COMMAND ${BASH_EXECUTABLE} ${PROJECT_SOURCE_DIR}/${ANIMUS_SCRIPTS_DIR}/activity_indicator.sh ${ACTIVITY_MESSAGE})
   list(APPEND ACTIVITY_FULL_COMMAND ${ACTIVITY_COMMAND})

   execute_process(COMMAND ${ACTIVITY_FULL_COMMAND} WORKING_DIRECTORY ${ACTIVITY_WORKING_DIRECTORY})
endfunction()

function(animus_git_initialization)
   file(GLOB JSON_DIR_RESULT "${PROJECT_SOURCE_DIR}/${ANIMUS_DEPS_DIR}/json/*")
   list(LENGTH JSON_DIR_RESULT JSON_DIR_RESULT_LEN)

   file(GLOB DJINNI_DIR_RESULT "${PROJECT_SOURCE_DIR}/${ANIMUS_DEPS_DIR}/djinni/*")
   list(LENGTH DJINNI_DIR_RESULT DJINNI_DIR_RESULT_LEN)

   if (JSON_DIR_RESULT_LEN EQUAL 0 OR DJINNI_DIR_RESULT_LEN EQUAL 0)
      execute_process_with_activity(
         COMMAND "${GIT_EXECUTABLE} submodule update --init --recursive"
         MESSAGE "Initializing and updating Git submodules"
         WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}
      )
   else()
      message("-- Git submodules have already been initialized and updated")
   endif()
endfunction()

function(animus_build_dependencies)
   if (NOT IS_DIRECTORY ${PROJECT_SOURCE_DIR}/${ANIMUS_DEPS_DIR}/djinni/src/target)
      execute_process_with_activity(
         COMMAND "${BASH_EXECUTABLE} build"
         MESSAGE "Building Djinni"
         WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}/${ANIMUS_DEPS_DIR}/djinni/src
      )
   else()
      message("-- Djinni is already built")
   endif()
endfunction()

macro(animus_bootstrap)
   set_property(GLOBAL PROPERTY USE_FOLDERS ON)
   cmake_policy(SET CMP0048 NEW)

   if(NOT CMAKE_BUILD_TYPE)
      set(CMAKE_BUILD_TYPE Debug)
   endif(NOT CMAKE_BUILD_TYPE)

   set(CMAKE_CXX_STANDARD 14)
   set(CMAKE_CXX_STANDARD_REQUIRED ON)

   string(TOLOWER ${PROJECT_NAME} ANIMUS_BINARY_NAME)

   set(ANIMUS_PROJECT_NAME ${PROJECT_NAME} CACHE STRING "The name of the project")
   set(ANIMUS_PROJECT_DESCRIPTION ${DESCRIPTION} CACHE STRING "The description of the project")
   set(ANIMUS_PROJECT_AUTHOR ${AUTHOR} CACHE STRING "The project author")
   set(ANIMUS_PROJECT_AUTHOR_EMAIL ${EMAIL} CACHE STRING "The project authors email")
   set(ANIMUS_PROJECT_YEAR_COPYRIGHT ${YEAR} CACHE STRING "The copyright date")
   set(ANIMUS_PROJECT_IDENTIFIER ${CODE_IDENTIFIER} CACHE STRING "The project identifier")
   set(ANIMUS_CPP_NAMESPACE "${ANIMUS_BINARY_NAME}_generated" CACHE STRING "Namespace of the generated C++")
   set(ANIMUS_JAVA_PACKAGE ${ANIMUS_PROJECT_IDENTIFIER} CACHE STRING "Namespace of the generated Java package")
   set(ANIMUS_JNI_NAMESPACE "${ANIMUS_BINARY_NAME}_jni" CACHE STRING "Namespace of the generated JNI C++")
   set(ANIMUS_OBJC_TYPE_PREFIX "" CACHE STRING "Prefix for generated Objective-C code")
   set(ANIMUS_OBJCPP_NAMESPACE "${ANIMUS_BINARY_NAME}_objc" CACHE STRING "Namespace of the generated Objective-C")
   set(ANIMUS_IDENT_CPP_ENUM "foo_bar" CACHE STRING "C++ enumeration style")
   set(ANIMUS_IDENT_CPP_FIELD "foo_bar" CACHE STRING "C++ field style")
   set(ANIMUS_IDENT_CPP_METHOD "foo_bar" CACHE STRING "C++ method style")
   set(ANIMUS_IDENT_CPP_ENUM_TYPE "foo_bar" CACHE STRING "C++ enumeration type style")
   set(ANIMUS_IDENT_CPP_TYPE_PARAM "foo_bar" CACHE STRING "C++ parameter type style")
   set(ANIMUS_IDENT_CPP_LOCAL "foo_bar" CACHE STRING "C++ local style")
   set(ANIMUS_IDENT_CPP_FILE "foo_bar" CACHE STRING "C++ file style")
   set(ANIMUS_IDENT_CPP_TYPE "foo_bar" CACHE STRING "C++ type style")
   set(ANIMUS_IDENT_JAVA_FIELD "mFooBar" CACHE STRING "Java field style")
   set(ANIMUS_IDENT_JNI_CLASS "NativeFooBar" CACHE STRING "JNI class style")
   set(ANIMUS_IDENT_JNI_FILE "native_foo_bar" CACHE STRING "JNI file style")

   if (${CMAKE_GENERATOR} STREQUAL Xcode)
      set(ANIMUS_WITH_OBJC ON CACHE BOOL "Build project with Objective-C support")
      set(ANIMUS_WITH_JNI OFF CACHE BOOL "Build project with JNI support")
   else()
      set(ANIMUS_WITH_OBJC OFF CACHE BOOL "Build project with Objective-C support")
      set(ANIMUS_WITH_JNI ON CACHE BOOL "Build project with JNI support")
   endif()

   set(ANIMUS_CMAKE_INCLUDE cmake/include)
   set(ANIMUS_CMAKE_MODULES cmake/modules)
   set(ANIMUS_SCRIPTS_DIR scripts)
   set(ANIMUS_INSTALL_DIR install)
   set(ANIMUS_DEPS_DIR deps)
   set(ANIMUS_SRC_DIR src)
   set(ANIMUS_CPP_SRC_DIR ${ANIMUS_SRC_DIR}/cpp)
   set(ANIMUS_OBJC_SRC_DIR ${ANIMUS_SRC_DIR}/objc)
   set(ANIMUS_JAVA_SRC_DIR ${ANIMUS_SRC_DIR}/java)
   set(ANIMUS_RC_DIR rc)
   set(ANIMUS_DJINNI_DIR ${ANIMUS_RC_DIR}/djinni)
   set(ANIMUS_GEN_DIR ${PROJECT_BINARY_DIR}/generated)
   set(ANIMUS_INTERFACE_DIR ${ANIMUS_GEN_DIR}/interface)
   set(ANIMUS_JNI_DIR ${ANIMUS_GEN_DIR}/jni)
   set(ANIMUS_OBJC_DIR ${ANIMUS_GEN_DIR}/objc)
   set(ANIMUS_JAVA_DIR ${ANIMUS_GEN_DIR}/java)
   set(ANIMUS_INTERFACE_DEFINITION ${PROJECT_SOURCE_DIR}/${ANIMUS_DJINNI_DIR}/interface_definition.djinni)
   set(ANIMUS_OBJC_UMBRELLA_HEADER ${ANIMUS_OBJC_DIR}/${ANIMUS_PROJECT_NAME}.h)

   set(PROJECT_RUNTIME_OUTPUT_DIRECTORY bin)
   set(PROJECT_LIBRARY_OUTPUT_DIRECTORY lib)
   set(PROJECT_ARCHIVE_OUTPUT_DIRECTORY lib/static)
   set(PROJECT_INCLUDE_OUTPUT_DIRECTORY include)
   set(PROJECT_SHARE_OUTPUT_DIRECTORY share)

   set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${PROJECT_RUNTIME_OUTPUT_DIRECTORY})
   set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${PROJECT_LIBRARY_OUTPUT_DIRECTORY})
   set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${PROJECT_ARCHIVE_OUTPUT_DIRECTORY})

   set(DJINNI_EXECUTABLE_DIR ${PROJECT_SOURCE_DIR}/${ANIMUS_DEPS_DIR}/djinni/src)
   set(DJINNI_EXECUTABLE ${DJINNI_EXECUTABLE_DIR}/run-assume-built)
endmacro()

macro(animus_add_subdirectories)
   set(DJINNI_WITH_OBJC ${ANIMUS_WITH_OBJC} CACHE BOOL "Build Djinni with Objective-C support")
   set(DJINNI_WITH_JNI ${ANIMUS_WITH_JNI} CACHE BOOL "Build Djinni with JNI support")
   set(DJINNI_STATIC_LIB ON CACHE BOOL "Build Djinni support library as a static library instead of dynamic")
   add_subdirectory(${ANIMUS_DEPS_DIR}/djinni)
   add_subdirectory(${ANIMUS_SRC_DIR})
endmacro()

macro(animus_build_message)
   message("-- " ${ANIMUS_PROJECT_NAME} " v" ${PROJECT_VERSION} " [" ${CMAKE_BUILD_TYPE} "]")
   message("-- Copyright © " ${ANIMUS_PROJECT_YEAR_COPYRIGHT} " " ${ANIMUS_PROJECT_AUTHOR}  " <" ${ANIMUS_PROJECT_AUTHOR_EMAIL} ">")
endmacro()
