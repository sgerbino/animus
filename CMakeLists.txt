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

string(TOLOWER ${PROJECT_NAME} LIBRARY_NAME)

set(CPP_NAMESPACE "${LIBRARY_NAME}_generated" CACHE STRING "Namespace of the generated C++")
set(JAVA_PACKAGE ${CODE_IDENTIFIER} CACHE STRING "Namespace of the generated Java package")
set(JNI_NAMESPACE "${LIBRARY_NAME}_jni" CACHE STRING "Namespace of the generated JNI C++")
set(OBJC_TYPE_PREFIX "" CACHE STRING "Prefix for generated Objective-C code")
set(OBJCPP_NAMESPACE "${LIBRARY_NAME}_objc" CACHE STRING "Namespace of the generated Objective-C")
set(IDENT_CPP_ENUM "foo_bar" CACHE STRING "C++ enumeration style")
set(IDENT_CPP_FIELD "foo_bar" CACHE STRING "C++ field style")
set(IDENT_CPP_METHOD "foo_bar" CACHE STRING "C++ method style")
set(IDENT_CPP_ENUM_TYPE "foo_bar" CACHE STRING "C++ enumeration type style")
set(IDENT_CPP_TYPE_PARAM "foo_bar" CACHE STRING "C++ parameter type style")
set(IDENT_CPP_LOCAL "foo_bar" CACHE STRING "C++ local style")
set(IDENT_CPP_FILE "foo_bar" CACHE STRING "C++ file style")
set(IDENT_CPP_TYPE "foo_bar" CACHE STRING "C++ type style")
set(IDENT_JAVA_FIELD "mFooBar" CACHE STRING "Java field style")
set(IDENT_JNI_CLASS "NativeFooBar" CACHE STRING "JNI class style")
set(IDENT_JNI_FILE "native_foo_bar" CACHE STRING "JNI file style")

if (${CMAKE_GENERATOR} STREQUAL Xcode)
   set(WITH_OBJC ON CACHE BOOL "Build project with Objective-C support")
   set(WITH_JNI OFF CACHE BOOL "Build project with JNI support")
else()
   set(WITH_OBJC OFF CACHE BOOL "Build project with Objective-C support")
   set(WITH_JNI ON CACHE BOOL "Build project with JNI support")
endif()

set(INSTALL_DIR install)
set(DEPS_DIR deps)
set(SRC_DIR src)
set(CPP_SRC_DIR ${SRC_DIR}/cpp)
set(OBJC_SRC_DIR ${SRC_DIR}/objc)
set(JAVA_SRC_DIR ${SRC_DIR}/java)
set(RC_DIR rc)
set(DJINNI_DIR ${RC_DIR}/djinni)
set(GEN_DIR ${PROJECT_BINARY_DIR}/generated)
set(INTERFACE_DIR ${GEN_DIR}/interface)
set(JNI_DIR ${GEN_DIR}/jni)
set(OBJC_DIR ${GEN_DIR}/objc)
set(JAVA_DIR ${GEN_DIR}/java)
set(INTERFACE_DEFINITION ${PROJECT_SOURCE_DIR}/${DJINNI_DIR}/interface_definition.djinni)
set(OBJC_UMBRELLA_HEADER ${OBJC_DIR}/${PROJECT_NAME}.h)

set(PROJECT_RUNTIME_OUTPUT_DIRECTORY bin)
set(PROJECT_LIBRARY_OUTPUT_DIRECTORY lib)
set(PROJECT_ARCHIVE_OUTPUT_DIRECTORY lib/static)
set(PROJECT_INCLUDE_OUTPUT_DIRECTORY include)
set(PROJECT_SHARE_OUTPUT_DIRECTORY share)

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${PROJECT_RUNTIME_OUTPUT_DIRECTORY})
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${PROJECT_LIBRARY_OUTPUT_DIRECTORY})
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${PROJECT_ARCHIVE_OUTPUT_DIRECTORY})

set(DJINNI_WITH_OBJC ${WITH_OBJC} CACHE BOOL "Build Djinni with Objective-C support")
set(DJINNI_WITH_JNI ${WITH_JNI} CACHE BOOL "Build Djinni with JNI support")
set(DJINNI_STATIC_LIB ON CACHE BOOL "Build Djinni support library as a static library instead of dynamic")
add_subdirectory(${DEPS_DIR}/djinni)
list(APPEND DJINNI_COMMAND ${DJINNI_RUN_PATH} --cpp-out ${INTERFACE_DIR})
if (DJINNI_WITH_JNI)
   list(APPEND DJINNI_COMMAND --java-out ${JAVA_DIR} --jni-out ${JNI_DIR})
endif()
if (DJINNI_WITH_OBJC)
   list(APPEND DJINNI_COMMAND --objc-out ${OBJC_DIR} --objcpp-out ${OBJC_DIR})
endif()
if (OBJC_TYPE_PREFIX)
   list(APPEND DJINNI_COMMAND --objc-type-prefix "${OBJC_TYPE_PREFIX}")
endif()
list(APPEND DJINNI_COMMAND
   --objcpp-include-cpp-prefix interface/
   --jni-include-cpp-prefix interface/
   --cpp-optional-header "\"<optional>\""
   --cpp-optional-template std::optional
   --cpp-namespace ${CPP_NAMESPACE}
   --java-package ${JAVA_PACKAGE}
   --jni-namespace ${JNI_NAMESPACE}
   --objcpp-namespace ${OBJCPP_NAMESPACE}
   --ident-cpp-enum ${IDENT_CPP_ENUM}
   --ident-cpp-field ${IDENT_CPP_FIELD}
   --ident-cpp-method ${IDENT_CPP_METHOD}
   --ident-cpp-enum-type ${IDENT_CPP_ENUM_TYPE}
   --ident-cpp-type-param ${IDENT_CPP_TYPE_PARAM}
   --ident-cpp-local ${IDENT_CPP_LOCAL}
   --ident-cpp-file ${IDENT_CPP_FILE}
   --ident-cpp-type ${IDENT_CPP_TYPE}
   --ident-java-field ${IDENT_JAVA_FIELD}
   --ident-jni-class ${IDENT_JNI_CLASS}
   --ident-jni-file ${IDENT_JNI_FILE}
   --idl ${INTERFACE_DEFINITION})

execute_process(COMMAND ${DJINNI_COMMAND} --skip-generation true --list-out-files ${CMAKE_CURRENT_BINARY_DIR}/djinni.out)

file(STRINGS ${PROJECT_BINARY_DIR}/djinni.out DJINNI_GENERATED_FILES)
message("-- Djinni will generate the following files: ")
foreach(ITEM ${DJINNI_GENERATED_FILES})
   message("--  `-> ${ITEM}")
   get_filename_component(ITEM_DIRECTORY ${ITEM} DIRECTORY)
   get_filename_component(ITEM_NAME ${ITEM} NAME)
   if (${ITEM_DIRECTORY} STREQUAL ${JNI_DIR})
      list(APPEND DJINNI_JNI_FILES ${ITEM_DIRECTORY}/${ITEM_NAME})
   endif()
   if (${ITEM_DIRECTORY} STREQUAL ${OBJC_DIR})
      list(APPEND DJINNI_OBJC_FILES ${ITEM_DIRECTORY}/${ITEM_NAME})
      if (${ITEM_NAME} MATCHES "\\.h$" AND NOT ${ITEM_NAME} MATCHES "\\+Private\\.h$")
         list(APPEND DJINNI_OBJC_HEADER_FILES ${ITEM_NAME})
         list(APPEND DJINNI_OBJC_HEADER_FILES_WITH_PATH ${ITEM_DIRECTORY}/${ITEM_NAME})
      endif()
   endif()
   if (${ITEM_DIRECTORY} STREQUAL ${JAVA_DIR})
      list(APPEND DJINNI_JAVA_FILES ${ITEM_DIRECTORY}/${ITEM_NAME})
   endif()
   if (${ITEM_DIRECTORY} STREQUAL ${INTERFACE_DIR})
      list(APPEND DJINNI_INTERFACE_FILES ${ITEM_DIRECTORY}/${ITEM_NAME})
   endif()
endforeach()

message("-- Generating Objective-C umbrella header (${OBJC_UMBRELLA_HEADER})")
file(REMOVE ${OBJC_UMBRELLA_HEADER})
list(APPEND DJINNI_OBJC_HEADER_FILES ${OBJC_HEADERS})
foreach(ITEM IN LISTS DJINNI_OBJC_HEADER_FILES)
   message("--  `-> Including ${ITEM}")
   file(APPEND ${OBJC_UMBRELLA_HEADER} "#import \"${ITEM}\"\n")
endforeach()

list(APPEND DJINNI_OUTPUT_FILES ${DJINNI_JNI_FILES} ${DJINNI_OBCJ_FILES} ${DJINNI_JAVA_FILES} ${DJINNI_INTERFACE_FILES})

add_custom_command(
   OUTPUT ${DJINNI_GENERATED_FILES}
   COMMAND ${DJINNI_COMMAND}
   WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}
   DEPENDS ${INTERFACE_DEFINITION})

add_custom_target(djinni
   DEPENDS ${DJINNI_OUTPUT_FILES}
   SOURCES
      ${INTERFACE_DEFINITION}
      ${DJINNI_DIR}/thread_launcher.djinni
      ${DJINNI_DIR}/event_loop.djinni
      ${DJINNI_DIR}/http.djinni)

add_subdirectory(${SRC_DIR})

if (${WITH_JNI})
   set(JNI_LIBRARY ${LIBRARY_NAME}_jni)
   add_library(${JNI_LIBRARY} SHARED ${DJINNI_JNI_FILES})
   target_include_directories(${JNI_LIBRARY} PUBLIC ${GEN_DIR} ${JNI_INCLUDE_DIRS} ${DJINNI_JNI_INCLUDE_DIR})
   target_link_libraries(${JNI_LIBRARY} ${LIBRARY_NAME} djinni_support_lib)
   set_target_properties(${JNI_LIBRARY} PROPERTIES PROJECT_LABEL "JNI")
endif()

if (${WITH_OBJC})
   foreach(OBJC_HEADER IN LISTS OBJC_HEADERS)
      list(APPEND OBJC_IMPLEMENTATION_FILES ${OBJC_SRC_DIR}/${OBJC_HEADER})
   endforeach()
   foreach(OBJC_SOURCE IN LISTS OBJC_SOURCES)
      list(APPEND OBJC_IMPLEMENTATION_FILES ${OBJC_SRC_DIR}/${OBJC_SOURCE})
   endforeach()
   set(OBJC_LIBRARY ${LIBRARY_NAME}_objc)
   list(APPEND OBJC_FILES ${OBJC_UMBRELLA_HEADER} ${DJINNI_OBJC_FILES})
   set_source_files_properties(${OBJC_FILES} PROPERTIES GENERATED TRUE)
   source_group("Interface Files" FILES ${OBJC_FILES})
   add_library(${OBJC_LIBRARY} SHARED ${OBJC_FILES} ${OBJC_IMPLEMENTATION_FILES})
   target_include_directories(${OBJC_LIBRARY} PUBLIC ${GEN_DIR}/objc)
   target_link_libraries(${OBJC_LIBRARY} ${LIBRARY_NAME} djinni_support_lib)
   list(APPEND DJINNI_OBJC_HEADER_FILES_WITH_PATH ${OBJC_DIR}/${PROJECT_NAME}.h)
   foreach(OBJC_HEADER IN LISTS OBJC_HEADERS)
      list(APPEND DJINNI_OBJC_HEADER_FILES_WITH_PATH ${OBJC_SRC_DIR}/${OBJC_HEADER})
   endforeach()
   set_target_properties(${OBJC_LIBRARY} PROPERTIES
      FRAMEWORK TRUE
      FRAMEWORK_VERSION A
      MACOSX_FRAMEWORK_IDENTIFIER ${CODE_IDENTIFIER}
      VERSION ${PROJECT_VERSION}
      SOVERSION ${PROJECT_VERSION}
      PUBLIC_HEADER "${DJINNI_OBJC_HEADER_FILES_WITH_PATH}"
      XCODE_ATTRIBUTE_CODE_SIGN_IDENTITY "${CODE_SIGN_IDENTITY}"
      XCODE_ATTRIBUTE_CODE_SIGN_REQUIRED NO
      XCODE_ATTRIBUTE_CLANG_ENABLE_OBJC_ARC YES
      XCODE_ATTRIBUTE_DEFINES_MODULE YES
      PROJECT_LABEL "Objective-C/C++"
      OUTPUT_NAME ${PROJECT_NAME})
endif()

message("-- " ${PROJECT_NAME} " v" ${PROJECT_VERSION} " [" ${CMAKE_BUILD_TYPE} "]")
message("-- Copyright © " ${YEAR} " " ${AUTHOR}  " <" ${EMAIL} ">")
