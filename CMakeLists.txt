set(PROJECT_NAME "waypoint_core" CACHE STRING "The name of the project")
set(PROJECT_DESCRIPTION "A cross compiling cmake project" CACHE STRING "The description of the project")
set(PROJECT_AUTHOR "Steve Gerbino" CACHE STRING "The project author")
set(PROJECT_AUTHOR_EMAIL "steve@gerbino.co" CACHE STRING "The project authors email")
set(PROJECT_YEAR_COPYRIGHT "2017" CACHE STRING "The copyright date")
set(TARGET_DJINNI_CMAKE ${PROJECT_NAME} CACHE STRING "The cmake target and library name")

project(${PROJECT_NAME})
cmake_minimum_required(VERSION 3.0)

if(NOT CMAKE_BUILD_TYPE)
        set(CMAKE_BUILD_TYPE Debug)
endif(NOT CMAKE_BUILD_TYPE)

if(NOT LIBRARY_TYPE)
    set(LIBRARY_TYPE "Shared")
endif(NOT LIBRARY_TYPE)

set(PROJECT_VERSION_MAJOR 0)
set(PROJECT_VERSION_MINOR 1)
set(PROJECT_VERSION_PATCH 0)
set(PROJECT_VERSION ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}.${PROJECT_VERSION_PATCH})

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
set(PROJECT_JNI_DIR jni)
set(PROJECT_OBJC_DIR objc)
set(PROJECT_JAVA_DIR java)
set(PROJECT_DOCS_DIR docs)
set(PROJECT_SRC_DIR src)
set(PROJECT_TEST_DIR test)
set(PROJECT_CONF_DIR conf)

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
find_program(MAKE_EXECUTABLE make)
find_program(BASH_EXECUTABLE bash)

set(UPDATE_DEPENDENCIES ${BASH_EXECUTABLE} ${PROJECT_SCRIPTS_DIR}/activity_indicator.sh "Updating and initializing Git submodules" "${GIT_EXECUTABLE} submodule update --init --recursive" "Git submodules initialized and updated")
set(BUILD_DJINNI ${BASH_EXECUTABLE} ${PROJECT_SCRIPTS_DIR}/activity_indicator.sh "Building Djinni" "${BASH_EXECUTABLE} build" "Djinni built")

file(GLOB JSON_DIR_RESULT "${PROJECT_SOURCE_DIR}/${PROJECT_DEPS_DIR}/json/*")
list(LENGTH JSON_DIR_RESULT JSON_DIR_RESULT_LEN)

file(GLOB DJINNI_DIR_RESULT "${PROJECT_SOURCE_DIR}/${PROJECT_DEPS_DIR}/djinni/*")
list(LENGTH DJINNI_DIR_RESULT DJINNI_DIR_RESULT_LEN)

if (JSON_DIR_RESULT_LEN EQUAL 0 OR DJINNI_DIR_RESULT_LEN EQUAL 0)
   execute_process(COMMAND ${UPDATE_DEPENDENCIES} WORKING_DIRECTORY ${PROJECT_SOURCE_DIR})
else()
   message("-- Git submodules have already been initialized and updated")
endif()

if (NOT EXISTS "${PROJECT_SOURCE_DIR}/${PROJECT_DEPS_DIR}/djinni/src/target/start")
   execute_process(COMMAND ${BUILD_DJINNI} WORKING_DIRECTORY {$PROJECT_SOURCE_DIR}/${PROJECT_DEPS_DIR}/djinni)
else()
   message("-- Djinni is already built")
endif()

find_package(Json REQUIRED)
include_directories(${JSON_INCLUDE_DIRS})
message("-- Json include directories: " ${JSON_INCLUDE_DIRS})

find_package(Djinni REQUIRED)
message("-- Djinni executable: " ${DJINNI_EXECUTABLE})

set(DJINNI_COMMAND ${DJINNI_EXECUTABLE}
      --cpp-out ${PROJECT_SRC_DIR}/interface
      --java-out ${PROJECT_JAVA_DIR}
      --jni-out ${PROJECT_JNI_DIR}
      --objc-out ${PROJECT_OBJC_DIR}
      --objcpp-out ${PROJECT_OBJC_DIR}
      --objcpp-include-cpp-prefix interface/
      --jni-include-cpp-prefix interface/
      --cpp-optional-header "\"<experimental/optional>\""
      --cpp-optional-template std::experimental::optional
      --idl ${PROJECT_SOURCE_DIR}/conf/mobile++.djinni
)

execute_process(COMMAND ${DJINNI_COMMAND} --skip-generation true --list-out-files djinni.out OUTPUT_QUIET)
file(STRINGS ${PROJECT_BINARY_DIR}/djinni.out DJINNI_GENERATED_FILES)
message("-- Djinni will generate the following files: ${DJINNI_GENERATED_FILES}")

add_custom_command(
   OUTPUT ${DJINNI_GENERATED_FILES}
   COMMAND ${DJINNI_COMMAND}
   WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}
   DEPENDS ${PROJECT_CONF_DIR}/mobile++.djinni
)

add_custom_target(djinni ALL DEPENDS ${DJINNI_GENERATED_FILES})

include_directories(${PROJECT_SRC_DIR}/interface)

add_subdirectory(${PROJECT_SRC_DIR})

if(DOXYGEN_FOUND)
    add_subdirectory(${PROJECT_DOCS_DIR})
endif(DOXYGEN_FOUND)


add_subdirectory(${PROJECT_TEST_DIR})

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

message("--")
message("-- " ${PROJECT_BUILD_MESSAGE})
message("-- " ${COPYRIGHT_BUILD_MESSAGE})
message("--")
