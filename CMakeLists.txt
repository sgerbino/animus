set(PROJECT_NAME "animus" CACHE STRING "The name of the project")
set(PROJECT_DESCRIPTION "A cross compiling cmake project" CACHE STRING "The description of the project")
set(PROJECT_AUTHOR "Steve Gerbino" CACHE STRING "The project author")
set(PROJECT_AUTHOR_EMAIL "steve@gerbino.co" CACHE STRING "The project authors email")
set(PROJECT_YEAR_COPYRIGHT "2017" CACHE STRING "The copyright date")
set(TARGET_DJINNI_CMAKE ${PROJECT_NAME} CACHE STRING "The cmake target and library name")
set(PROJECT_WITH_JNI ON CACHE BOOL "Build project with JNI support")
if (${CMAKE_GENERATOR} STREQUAL Xcode)
   set(PROJECT_WITH_OBJC ON CACHE BOOL "Build project with Objective-C support")
else()
   set(PROJECT_WITH_OBJC OFF CACHE BOOL "Build project with Objective-C support")
endif()


set_property(GLOBAL PROPERTY USE_FOLDERS ON)
cmake_policy(SET CMP0048 NEW)
project(${PROJECT_NAME} VERSION 1.0.0.0)
cmake_minimum_required(VERSION 3.6)

if(NOT CMAKE_BUILD_TYPE)
        set(CMAKE_BUILD_TYPE Debug)
endif(NOT CMAKE_BUILD_TYPE)

if(NOT LIBRARY_TYPE)
    set(LIBRARY_TYPE "Shared")
endif(NOT LIBRARY_TYPE)

set(PROJECT_BUILD_MESSAGE ${PROJECT_NAME} " v" ${PROJECT_VERSION} " (" ${LIBRARY_TYPE} "." ${CMAKE_BUILD_TYPE} ")")
set(COPYRIGHT_BUILD_MESSAGE "Copyright (c) " ${PROJECT_YEAR_COPYRIGHT} " " ${PROJECT_AUTHOR}  " <" ${PROJECT_AUTHOR_EMAIL} ">")

#
# Compile stuff
#

if(APPLE)
    set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -Wl,-undefined,dynamic_lookup")
else(APPLE)
    set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -Wl,--export-dynamic")
endif(APPLE)

set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wall")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall")
set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -O0 -g -DDEBUG")
set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -Os -DRELEASE")

add_definitions(-DPROJECT_NAME=${PROJECT_NAME} -DPROJECT_VERSION="${PROJECT_VERSION}")

#
# CMake configuration
#

set(PROJECT_CMAKE_CLEAN cmake/clean)
set(PROJECT_CMAKE_MODULES cmake/modules)
set(PROJECT_SCRIPTS_DIR scripts)
set(PROJECT_INSTALL_DIR install)
set(PROJECT_BUILD_DIR build)
set(PROJECT_DEPS_DIR deps)
set(PROJECT_DOCS_DIR docs)
set(PROJECT_SRC_DIR src)
set(PROJECT_TEST_DIR test)
set(PROJECT_CONF_DIR conf)
set(PROJECT_GEN_DIR ${CMAKE_BINARY_DIR}/gen)
set(PROJECT_INTERFACE_DIR ${PROJECT_GEN_DIR}/interface)
set(PROJECT_JNI_DIR ${PROJECT_GEN_DIR}/jni)
set(PROJECT_OBJC_DIR ${PROJECT_GEN_DIR}/objc)
set(PROJECT_JAVA_DIR ${PROJECT_GEN_DIR}/java)
set(PROJECT_INTERFACE_DEFINITION ${PROJECT_SOURCE_DIR}/${PROJECT_CONF_DIR}/interface_definition.djinni)

set(PROJECT_RUNTIME_OUTPUT_DIRECTORY bin)
set(PROJECT_LIBRARY_OUTPUT_DIRECTORY lib)
set(PROJECT_ARCHIVE_OUTPUT_DIRECTORY lib/static)
set(PROJECT_INCLUDE_OUTPUT_DIRECTORY include)
set(PROJECT_SHARE_OUTPUT_DIRECTORY share)

set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${CMAKE_SOURCE_DIR}/${PROJECT_CMAKE_MODULES})
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${PROJECT_RUNTIME_OUTPUT_DIRECTORY})
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${PROJECT_LIBRARY_OUTPUT_DIRECTORY})
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${PROJECT_ARCHIVE_OUTPUT_DIRECTORY})

find_program(GIT_EXECUTABLE git)
find_program(BASH_EXECUTABLE bash)

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

   list(APPEND ACTIVITY_FULL_COMMAND ${BASH_EXECUTABLE} ${PROJECT_SOURCE_DIR}/${PROJECT_SCRIPTS_DIR}/activity_indicator.sh ${ACTIVITY_MESSAGE})
   list(APPEND ACTIVITY_FULL_COMMAND ${ACTIVITY_COMMAND})

   execute_process(COMMAND ${ACTIVITY_FULL_COMMAND} WORKING_DIRECTORY ${ACTIVITY_WORKING_DIRECTORY})
endfunction()

file(GLOB JSON_DIR_RESULT "${PROJECT_SOURCE_DIR}/${PROJECT_DEPS_DIR}/json/*")
list(LENGTH JSON_DIR_RESULT JSON_DIR_RESULT_LEN)

file(GLOB DJINNI_DIR_RESULT "${PROJECT_SOURCE_DIR}/${PROJECT_DEPS_DIR}/djinni/*")
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

if (NOT IS_DIRECTORY ${PROJECT_SOURCE_DIR}/${PROJECT_DEPS_DIR}/djinni/src/target)
   execute_process_with_activity(
      COMMAND "${BASH_EXECUTABLE} build"
      MESSAGE "Building Djinni"
      WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}/${PROJECT_DEPS_DIR}/djinni/src
   )
else()
   message("-- Djinni is already built")
endif()

find_package(JNI REQUIRED)
include_directories(${JNI_INCLUDE_DIRS})

find_package(Json REQUIRED)
include_directories(${JSON_INCLUDE_DIRS})
message("-- Json include directories: " ${JSON_INCLUDE_DIRS})

find_package(Djinni REQUIRED)
include_directories(${DJINNI_JNI_INCLUDE_DIR} ${DJINNI_OBJC_INCLUDE_DIR})
message("-- Djinni executable: " ${DJINNI_EXECUTABLE})

set(DJINNI_COMMAND ${DJINNI_EXECUTABLE}
      --cpp-out ${PROJECT_INTERFACE_DIR}
      --java-out ${PROJECT_JAVA_DIR}
      --jni-out ${PROJECT_JNI_DIR}
      --objc-out ${PROJECT_OBJC_DIR}
      --objcpp-out ${PROJECT_OBJC_DIR}
      --objcpp-include-cpp-prefix interface/
      --jni-include-cpp-prefix interface/
      --cpp-optional-header "\"<experimental/optional>\""
      --cpp-optional-template std::experimental::optional
      --idl ${PROJECT_INTERFACE_DEFINITION}
      --objc-type-prefix MPP
)

execute_process(COMMAND ${DJINNI_COMMAND} --skip-generation true --list-out-files djinni.out OUTPUT_QUIET)
file(STRINGS ${PROJECT_BINARY_DIR}/djinni.out DJINNI_GENERATED_FILES)
message("-- Djinni will generate the following files: ")
foreach(ITEM ${DJINNI_GENERATED_FILES})
   message("--  `-> ${ITEM}")
   get_filename_component(ITEM_DIRECTORY ${ITEM} DIRECTORY)
   get_filename_component(ITEM_NAME ${ITEM} NAME)
   if (${ITEM_DIRECTORY} STREQUAL ${PROJECT_JNI_DIR})
      list(APPEND DJINNI_JNI_FILES ${ITEM_DIRECTORY}/${ITEM_NAME})
   endif()
   if (${ITEM_DIRECTORY} STREQUAL ${PROJECT_OBJC_DIR})
      list(APPEND DJINNI_OBJC_FILES ${ITEM_DIRECTORY}/${ITEM_NAME})
   endif()
   if (${ITEM_DIRECTORY} STREQUAL ${PROJECT_JAVA_DIR})
      list(APPEND DJINNI_JAVA_FILES ${ITEM_DIRECTORY}/${ITEM_NAME})
   endif()
   if (${ITEM_DIRECTORY} STREQUAL ${PROJECT_INTERFACE_DIR})
      list(APPEND DJINNI_INTERFACE_FILES ${ITEM_DIRECTORY}/${ITEM_NAME})
   endif()
endforeach()

list(APPEND DJINNI_OUTPUT_FILES ${DJINNI_JNI_FILES} ${DJINNI_OBCJ_FILES} ${DJINNI_JAVA_FILES} ${DJINNI_INTERFACE_FILES})

add_custom_command(
   OUTPUT ${DJINNI_GENERATED_FILES}
   COMMAND ${DJINNI_COMMAND}
   WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}
   DEPENDS ${PROJECT_INTERFACE_DEFINITION}
)

add_custom_target(djinni DEPENDS ${DJINNI_OUTPUT_FILES} SOURCES ${PROJECT_INTERFACE_DEFINITION})

include_directories(${PROJECT_INTERFACE_DIR})

set(DJINNI_WITH_OBJC ${PROJECT_WITH_OBJC} CACHE BOOL "Build Djinni with Objective-C support")
set(DJINNI_WITH_JNI ${PROJECT_WITH_JNI} CACHE BOOL "Build Djinni with JNI support")
add_subdirectory(${PROJECT_DEPS_DIR}/djinni)
add_subdirectory(${PROJECT_SRC_DIR})
add_subdirectory(${PROJECT_TEST_DIR})

if (${PROJECT_WITH_JNI})
  set(PROJECT_JNI_LIBRARY ${PROJECT_NAME}-jni)
  add_library(${PROJECT_JNI_LIBRARY} SHARED ${DJINNI_JNI_FILES})
  target_include_directories(${PROJECT_JNI_LIBRARY} PUBLIC ${PROJECT_GEN_DIR})
  add_dependencies(${PROJECT_JNI_LIBRARY} ${PROJECT_NAME} djinni_support_lib)
endif()

if (${PROJECT_WITH_OBJC})
   set(PROJECT_OBJC_LIBRARY ${PROJECT_NAME}-objc)
   add_library(${PROJECT_OBJC_LIBRARY} SHARED ${DJINNI_OBJC_FILES})
   target_include_directories(${PROJECT_OBJC_LIBRARY} PUBLIC ${PROJECT_GEN_DIR})
   set_property (TARGET ${PROJECT_OBJC_LIBRARY} APPEND_STRING PROPERTY COMPILE_FLAGS "-fobjc-arc")
   add_dependencies(${PROJECT_OBJC_LIBRARY} ${PROJECT_NAME} djinni_support_lib)
endif()

#
# Keep your stuff and go further away, foolish.
#

set(CPACK_PACKAGE_NAME ${PROJECT_NAME})
set(CPACK_PACKAGE_VENDOR ${PROJECT_AUTHOR})
set(CPACK_PACKAGE_VERSION_MAJOR ${PROJECT_VERSION_MAJOR})
set(CPACK_PACKAGE_VERSION_MINOR ${PROJECT_VERSION_MINOR})
set(CPACK_PACKAGE_VERSION_PATCH ${PROJECT_VERSION_PATCH})
set(CPACK_PACKAGE_VERSION ${CPACK_PACKAGE_VERSION_MAJOR}.${CPACK_PACKAGE_VERSION_MINOR}.${CPACK_PACKAGE_VERSION_PATCH})
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY ${PROJECT_DESCRIPTION})
set(CPACK_PACKAGE_FILE_NAME ${CPACK_PACKAGE_NAME}-${CPACK_PACKAGE_VERSION})
set(CPACK_SOURCE_PACKAGE_FILE_NAME ${CPACK_PACKAGE_FILE_NAME}-src)
#set(CPACK_RESOURCE_FILE_LICENSE ${CMAKE_SOURCE_DIR}/LICENSE.txt)
#set(CPACK_RESOURCE_FILE_README ${CMAKE_SOURCE_DIR}/README.md)
set(CPACK_GENERATOR TGZ)
set(CPACK_SOURCE_GENERATOR TGZ)
set(CPACK_PACKAGING_INSTALL_DIRECTORY "${PROJECT_NAME}-${CMake_VERSION_MAJOR}.${CMake_VERSION_MINOR}")

include(CPack)

message("-- " ${PROJECT_BUILD_MESSAGE})
message("-- " ${COPYRIGHT_BUILD_MESSAGE})

