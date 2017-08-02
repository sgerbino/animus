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
