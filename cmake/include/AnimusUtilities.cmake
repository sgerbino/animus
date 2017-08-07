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

macro(animus_find_dependencies)
   find_package(JNI REQUIRED)
   find_package(Java REQUIRED)
   include(UseJava)
   find_package(Json REQUIRED)
   find_package(Djinni REQUIRED)
   include_directories(${DJINNI_JNI_INCLUDE_DIR} ${DJINNI_OBJC_INCLUDE_DIR})
endmacro()

macro(animus_bootstrap)
   string(TOLOWER ${ANIMUS_PROJECT_NAME} ANIMUS_BINARY_NAME)

   set_property(GLOBAL PROPERTY USE_FOLDERS ON)
   cmake_policy(SET CMP0048 NEW)
   project(${ANIMUS_PROJECT_NAME} VERSION 1.0.0.0)

   if(NOT CMAKE_BUILD_TYPE)
      set(CMAKE_BUILD_TYPE Debug)
   endif(NOT CMAKE_BUILD_TYPE)

   if(NOT LIBRARY_TYPE)
      set(LIBRARY_TYPE "Shared")
   endif(NOT LIBRARY_TYPE)

   if(APPLE)
      set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -Wl,-undefined,dynamic_lookup")
   else(APPLE)
      set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -Wl,--export-dynamic")
   endif(APPLE)

   set(CMAKE_CXX_STANDARD 14)
   set(CMAKE_CXX_STANDARD_REQUIRED ON)

   add_definitions(-DPROJECT_NAME=${ANIMUS_PROJECT_NAME} -DPROJECT_VERSION="${PROJECT_VERSION}")
endmacro()

macro(animus_add_subdirectories)
   set(DJINNI_WITH_OBJC ${ANIMUS_WITH_OBJC} CACHE BOOL "Build Djinni with Objective-C support")
   set(DJINNI_WITH_JNI ${ANIMUS_WITH_JNI} CACHE BOOL "Build Djinni with JNI support")
   set(DJINNI_STATIC_LIB ON CACHE BOOL "Build Djinni support library as a static library instead of dynamic")
   add_subdirectory(${ANIMUS_DEPS_DIR}/djinni)
   add_subdirectory(${ANIMUS_SRC_DIR})
   add_subdirectory(${ANIMUS_TEST_DIR})
endmacro()

macro(animus_build_message)
   message("-- " ${ANIMUS_PROJECT_NAME} " v" ${PROJECT_VERSION} " (" ${LIBRARY_TYPE} "::" ${CMAKE_BUILD_TYPE} ")")
   message("-- Copyright (c) " ${ANIMUS_PROJECT_YEAR_COPYRIGHT} " " ${ANIMUS_PROJECT_AUTHOR}  " <" ${ANIMUS_PROJECT_AUTHOR_EMAIL} ">")
endmacro()
