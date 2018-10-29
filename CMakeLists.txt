cmake_minimum_required(VERSION 3.6)
project(Animus VERSION 1.0.0.0)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(DESCRIPTION "An application core with bindings for Swift, Objective-C and Java")
set(AUTHOR "Steve Gerbino")
set(EMAIL steve@gerbino.co)
set(YEAR 2017)
set(CODE_IDENTIFIER io.github.animus)
set(CODE_SIGN_IDENTITY )

set(INTERFACE_DEFINITIONS
      event_loop.djinni
      http.djinni
      thread_launcher.djinni)

set(CPP_HEADERS
      api.hpp
      task_runner.hpp
      http.hpp
      event_loop.hpp)

set(CPP_SOURCES
      api.cpp
      http.cpp
      event_loop.cpp)

set(OBJC_HEADERS
      AppleEventLoop.h
      AppleHttp.h
      AppleThreadLauncher.h)

set(OBJC_SOURCES
      AppleEventLoop.m
      AppleHttp.m
      AppleThreadLauncher.m)

string(TOLOWER ${PROJECT_NAME} ANIMUS_BINARY_NAME)

set(ANIMUS_PROJECT_NAME ${PROJECT_NAME} CACHE STRING "The name of the project")
set(ANIMUS_PROJECT_DESCRIPTION ${DESCRIPTION} CACHE STRING "The description of the project")
set(ANIMUS_PROJECT_AUTHOR ${AUTHOR} CACHE STRING "The project author")
set(ANIMUS_PROJECT_AUTHOR_EMAIL ${EMAIL} CACHE STRING "The project authors email")
set(ANIMUS_PROJECT_YEAR_COPYRIGHT ${YEAR} CACHE STRING "The copyright date")
set(ANIMUS_PROJECT_IDENTIFIER ${CODE_IDENTIFIER} CACHE STRING "The project identifier")
set(ANIMUS_CODE_SIGN_IDENTITY ${CODE_SIGN_IDENTITY} CACHE STRING "The Xcode code sign identity")
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

set(DJINNI_WITH_OBJC ${ANIMUS_WITH_OBJC} CACHE BOOL "Build Djinni with Objective-C support")
set(DJINNI_WITH_JNI ${ANIMUS_WITH_JNI} CACHE BOOL "Build Djinni with JNI support")
set(DJINNI_STATIC_LIB ON CACHE BOOL "Build Djinni support library as a static library instead of dynamic")
add_subdirectory(${ANIMUS_DEPS_DIR}/djinni)
list(APPEND DJINNI_COMMAND ${DJINNI_RUN_PATH} --cpp-out ${ANIMUS_INTERFACE_DIR})
if (DJINNI_WITH_JNI)
   list(APPEND DJINNI_COMMAND --java-out ${ANIMUS_JAVA_DIR} --jni-out ${ANIMUS_JNI_DIR})
endif()
if (DJINNI_WITH_OBJC)
   list(APPEND DJINNI_COMMAND --objc-out ${ANIMUS_OBJC_DIR} --objcpp-out ${ANIMUS_OBJC_DIR})
endif()
if (ANIMUS_OBJC_TYPE_PREFIX)
   list(APPEND DJINNI_COMMAND --objc-type-prefix "${ANIMUS_OBJC_TYPE_PREFIX}")
endif()
list(APPEND DJINNI_COMMAND
   --objcpp-include-cpp-prefix interface/
   --jni-include-cpp-prefix interface/
   --cpp-optional-header "\"<optional>\""
   --cpp-optional-template std::optional
   --cpp-namespace ${ANIMUS_CPP_NAMESPACE}
   --java-package ${ANIMUS_JAVA_PACKAGE}
   --jni-namespace ${ANIMUS_JNI_NAMESPACE}
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

#execute_process(COMMAND ${DJINNI_COMMAND} --skip-generation true --list-out-files ${CMAKE_CURRENT_BINARY_DIR}/djinni.out OUTPUT_QUIET)
execute_process(COMMAND ${DJINNI_COMMAND} --skip-generation true --list-out-files ${CMAKE_CURRENT_BINARY_DIR}/djinni.out)

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
list(APPEND DJINNI_OBJC_HEADER_FILES ${OBJC_HEADERS})
foreach(ITEM IN LISTS DJINNI_OBJC_HEADER_FILES)
   message("--  `-> Including ${ITEM}")
   file(APPEND ${ANIMUS_OBJC_UMBRELLA_HEADER} "#import \"${ITEM}\"\n")
endforeach()

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

add_subdirectory(${ANIMUS_SRC_DIR})

if (${ANIMUS_WITH_JNI})
   set(ANIMUS_JNI_LIBRARY ${ANIMUS_BINARY_NAME}_jni)
   add_library(${ANIMUS_JNI_LIBRARY} SHARED ${DJINNI_JNI_FILES})
   target_include_directories(${ANIMUS_JNI_LIBRARY} PUBLIC ${ANIMUS_GEN_DIR} ${JNI_INCLUDE_DIRS} ${DJINNI_JNI_INCLUDE_DIR})
   target_link_libraries(${ANIMUS_JNI_LIBRARY} ${ANIMUS_BINARY_NAME} djinni_support_lib)
   set_target_properties(${ANIMUS_JNI_LIBRARY} PROPERTIES PROJECT_LABEL "JNI")
endif()

if (${ANIMUS_WITH_OBJC})
   foreach(OBJC_HEADER IN LISTS OBJC_HEADERS)
      list(APPEND ANIMUS_OBJC_IMPLEMENTATION_FILES ${ANIMUS_OBJC_SRC_DIR}/${OBJC_HEADER})
   endforeach()
   foreach(OBJC_SOURCE IN LISTS OBJC_SOURCES)
      list(APPEND ANIMUS_OBJC_IMPLEMENTATION_FILES ${ANIMUS_OBJC_SRC_DIR}/${OBJC_SOURCE})
   endforeach()
   set(ANIMUS_OBJC_LIBRARY ${ANIMUS_BINARY_NAME}_objc)
   list(APPEND ANIMUS_OBJC_FILES ${ANIMUS_OBJC_UMBRELLA_HEADER} ${DJINNI_OBJC_FILES})
   set_source_files_properties(${ANIMUS_OBJC_FILES} PROPERTIES GENERATED TRUE)
   source_group("Interface Files" FILES ${ANIMUS_OBJC_FILES})
   add_library(${ANIMUS_OBJC_LIBRARY} SHARED ${ANIMUS_OBJC_FILES} ${ANIMUS_OBJC_IMPLEMENTATION_FILES})
   target_include_directories(${ANIMUS_OBJC_LIBRARY} PUBLIC ${ANIMUS_GEN_DIR}/objc)
   target_link_libraries(${ANIMUS_OBJC_LIBRARY} ${ANIMUS_BINARY_NAME} djinni_support_lib)
   list(APPEND DJINNI_OBJC_HEADER_FILES_WITH_PATH ${ANIMUS_OBJC_DIR}/${ANIMUS_PROJECT_NAME}.h)
   foreach(OBJC_HEADER IN LISTS OBJC_HEADERS)
      list(APPEND DJINNI_OBJC_HEADER_FILES_WITH_PATH ${ANIMUS_OBJC_SRC_DIR}/${OBJC_HEADER})
   endforeach()
   set_target_properties(${ANIMUS_OBJC_LIBRARY} PROPERTIES
      FRAMEWORK TRUE
      FRAMEWORK_VERSION A
      MACOSX_FRAMEWORK_IDENTIFIER ${ANIMUS_PROJECT_IDENTIFIER}
      VERSION ${PROJECT_VERSION}
      SOVERSION ${PROJECT_VERSION}
      PUBLIC_HEADER "${DJINNI_OBJC_HEADER_FILES_WITH_PATH}"
      XCODE_ATTRIBUTE_CODE_SIGN_IDENTITY "${ANIMUS_CODE_SIGN_IDENTITY}"
      XCODE_ATTRIBUTE_CODE_SIGN_REQUIRED NO
      XCODE_ATTRIBUTE_CLANG_ENABLE_OBJC_ARC YES
      XCODE_ATTRIBUTE_DEFINES_MODULE YES
      PROJECT_LABEL "Objective-C/C++"
      OUTPUT_NAME ${ANIMUS_PROJECT_NAME})
endif()

message("-- " ${ANIMUS_PROJECT_NAME} " v" ${PROJECT_VERSION} " [" ${CMAKE_BUILD_TYPE} "]")
message("-- Copyright © " ${ANIMUS_PROJECT_YEAR_COPYRIGHT} " " ${ANIMUS_PROJECT_AUTHOR}  " <" ${ANIMUS_PROJECT_AUTHOR_EMAIL} ">")
