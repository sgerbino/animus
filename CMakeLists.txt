set(ANIMUS_PROJECT_NAME "Animus" CACHE STRING "The name of the project")
set(ANIMUS_PROJECT_DESCRIPTION "A cross compiling cmake project" CACHE STRING "The description of the project")
set(ANIMUS_PROJECT_AUTHOR "Steve Gerbino" CACHE STRING "The project author")
set(ANIMUS_PROJECT_AUTHOR_EMAIL "steve@gerbino.co" CACHE STRING "The project authors email")
set(ANIMUS_PROJECT_YEAR_COPYRIGHT "2017" CACHE STRING "The copyright date")
set(ANIMUS_PROJECT_IDENTIFIER "io.github.animus" CACHE STRING "The project identifier")
set(ANIMUS_WITH_JNI ON CACHE BOOL "Build project with JNI support")
if (${CMAKE_GENERATOR} STREQUAL Xcode)
   set(ANIMUS_WITH_OBJC ON CACHE BOOL "Build project with Objective-C support")
else()
   set(ANIMUS_WITH_OBJC OFF CACHE BOOL "Build project with Objective-C support")
endif()

#
# Djinni style configurations
#
set(ANIMUS_CPP_NAMESPACE "animus_generated" CACHE STRING "Namespace of the generated C++")
set(ANIMUS_JAVA_PACKAGE "io.github.animus" CACHE STRING "Namespace of the generated Java package")
set(ANIMUS_JNI_NAMESPACE "animus_jni" CACHE STRING "Namespace of the generated JNI C++")
set(ANIMUS_OBJC_TYPE_PREFIX "" CACHE STRING "Prefix for generated Objective-C code")
set(ANIMUS_OBJCPP_NAMESPACE "animus_objc" CACHE STRING "Namespace of the generated Objective-C")
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

string(TOLOWER ${ANIMUS_PROJECT_NAME} ANIMUS_BINARY_NAME)

set_property(GLOBAL PROPERTY USE_FOLDERS ON)
cmake_policy(SET CMP0048 NEW)
project(${ANIMUS_PROJECT_NAME} VERSION 1.0.0.0)
cmake_minimum_required(VERSION 3.6)

if(NOT CMAKE_BUILD_TYPE)
   set(CMAKE_BUILD_TYPE Debug)
endif(NOT CMAKE_BUILD_TYPE)

if(NOT LIBRARY_TYPE)
   set(LIBRARY_TYPE "Shared")
endif(NOT LIBRARY_TYPE)

set(ANIMUS_BUILD_MESSAGE ${ANIMUS_PROJECT_NAME} " v" ${PROJECT_VERSION} " (" ${LIBRARY_TYPE} "::" ${CMAKE_BUILD_TYPE} ")")
set(ANIMUS_COPYRIGHT_BUILD_MESSAGE "Copyright (c) " ${ANIMUS_PROJECT_YEAR_COPYRIGHT} " " ${ANIMUS_PROJECT_AUTHOR}  " <" ${ANIMUS_PROJECT_AUTHOR_EMAIL} ">")

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

add_definitions(-DPROJECT_NAME=${ANIMUS_PROJECT_NAME} -DPROJECT_VERSION="${PROJECT_VERSION}")

#
# CMake configuration
#

set(ANIMUS_CMAKE_CLEAN cmake/clean)
set(ANIMUS_CMAKE_MODULES cmake/modules)
set(ANIMUS_SCRIPTS_DIR scripts)
set(ANIMUS_INSTALL_DIR install)
set(ANIMUS_DEPS_DIR deps)
set(ANIMUS_SRC_DIR src)
set(ANIMUS_CPP_SRC_DIR ${ANIMUS_SRC_DIR}/cpp)
set(ANIMUS_OBJC_SRC_DIR ${ANIMUS_SRC_DIR}/objc)
set(ANIMUS_JAVA_SRC_DIR ${ANIMUS_SRC_DIR}/java)
set(ANIMUS_TEST_DIR test)
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

set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${CMAKE_SOURCE_DIR}/${ANIMUS_CMAKE_MODULES})
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

   list(APPEND ACTIVITY_FULL_COMMAND ${BASH_EXECUTABLE} ${PROJECT_SOURCE_DIR}/${ANIMUS_SCRIPTS_DIR}/activity_indicator.sh ${ACTIVITY_MESSAGE})
   list(APPEND ACTIVITY_FULL_COMMAND ${ACTIVITY_COMMAND})

   execute_process(COMMAND ${ACTIVITY_FULL_COMMAND} WORKING_DIRECTORY ${ACTIVITY_WORKING_DIRECTORY})
endfunction()

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

if (NOT IS_DIRECTORY ${PROJECT_SOURCE_DIR}/${ANIMUS_DEPS_DIR}/djinni/src/target)
   execute_process_with_activity(
      COMMAND "${BASH_EXECUTABLE} build"
      MESSAGE "Building Djinni"
      WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}/${ANIMUS_DEPS_DIR}/djinni/src
   )
else()
   message("-- Djinni is already built")
endif()

find_package(JNI REQUIRED)
include_directories(${JNI_INCLUDE_DIRS})

find_package(Java REQUIRED)
include(UseJava)

find_package(Json REQUIRED)
include_directories(${JSON_INCLUDE_DIRS})
message("-- Json include directories: " ${JSON_INCLUDE_DIRS})

find_package(Djinni REQUIRED)
include_directories(${DJINNI_JNI_INCLUDE_DIR} ${DJINNI_OBJC_INCLUDE_DIR})
message("-- Djinni executable: " ${DJINNI_EXECUTABLE})

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
      --idl ${ANIMUS_INTERFACE_DEFINITION}
)

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

list(APPEND DJINNI_OUTPUT_FILES ${DJINNI_JNI_FILES} ${DJINNI_OBCJ_FILES} ${DJINNI_JAVA_FILES} ${DJINNI_INTERFACE_FILES})

add_custom_command(
   OUTPUT ${DJINNI_GENERATED_FILES}
   COMMAND ${DJINNI_COMMAND}
   WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}
   DEPENDS ${ANIMUS_INTERFACE_DEFINITION}
)

add_custom_target(djinni
   DEPENDS ${DJINNI_OUTPUT_FILES}
   SOURCES
      ${ANIMUS_INTERFACE_DEFINITION}
      ${ANIMUS_DJINNI_DIR}/thread_launcher.djinni
      ${ANIMUS_DJINNI_DIR}/event_loop.djinni
      ${ANIMUS_DJINNI_DIR}/http.djinni
)

set(DJINNI_WITH_OBJC ${ANIMUS_WITH_OBJC} CACHE BOOL "Build Djinni with Objective-C support")
set(DJINNI_WITH_JNI ${ANIMUS_WITH_JNI} CACHE BOOL "Build Djinni with JNI support")
set(DJINNI_STATIC_LIB ON CACHE BOOL "Build Djinni support library as a static library instead of dynamic")
add_subdirectory(${ANIMUS_DEPS_DIR}/djinni)
add_subdirectory(${ANIMUS_SRC_DIR})
add_subdirectory(${ANIMUS_TEST_DIR})

if (${ANIMUS_WITH_JNI})
   set(ANIMUS_JNI_LIBRARY ${ANIMUS_BINARY_NAME}-jni)
   add_library(${ANIMUS_JNI_LIBRARY} SHARED ${DJINNI_JNI_FILES})
   target_include_directories(${ANIMUS_JNI_LIBRARY} PUBLIC ${ANIMUS_GEN_DIR})
   target_link_libraries(${ANIMUS_JNI_LIBRARY} ${ANIMUS_BINARY_NAME} djinni_support_lib)
   set_target_properties(${ANIMUS_JNI_LIBRARY} PROPERTIES PROJECT_LABEL "Djinni JNI")
endif()

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
      XCODE_ATTRIBUTE_CODE_SIGN_IDENTITY "iPhone Developer"
      XCODE_ATTRIBUTE_CLANG_ENABLE_OBJC_ARC YES
      PROJECT_LABEL "Djinni Objective-C/C++"
      OUTPUT_NAME ${ANIMUS_PROJECT_NAME}
   )
endif()

set(CPACK_PACKAGE_NAME ${PROJECT_NAME})
set(CPACK_PACKAGE_VENDOR ${PROJECT_AUTHOR})
set(CPACK_PACKAGE_VERSION_MAJOR ${PROJECT_VERSION_MAJOR})
set(CPACK_PACKAGE_VERSION_MINOR ${PROJECT_VERSION_MINOR})
set(CPACK_PACKAGE_VERSION_PATCH ${PROJECT_VERSION_PATCH})
set(CPACK_PACKAGE_VERSION ${CPACK_PACKAGE_VERSION_MAJOR}.${CPACK_PACKAGE_VERSION_MINOR}.${CPACK_PACKAGE_VERSION_PATCH})
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY ${PROJECT_DESCRIPTION})
set(CPACK_PACKAGE_FILE_NAME ${CPACK_PACKAGE_NAME}-${CPACK_PACKAGE_VERSION})
set(CPACK_SOURCE_PACKAGE_FILE_NAME ${CPACK_PACKAGE_FILE_NAME}-src)
set(CPACK_RESOURCE_FILE_LICENSE ${CMAKE_SOURCE_DIR}/LICENSE)
set(CPACK_RESOURCE_FILE_README ${CMAKE_SOURCE_DIR}/README.md)
set(CPACK_GENERATOR TGZ)
set(CPACK_SOURCE_GENERATOR TGZ)
set(CPACK_PACKAGING_INSTALL_DIRECTORY "${PROJECT_NAME}-${CMake_VERSION_MAJOR}.${CMake_VERSION_MINOR}")

include(CPack)

message("-- " ${ANIMUS_BUILD_MESSAGE})
message("-- " ${ANIMUS_COPYRIGHT_BUILD_MESSAGE})

