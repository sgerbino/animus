# This module defines:
#
# ::
#
#   JSON_INCLUDE_DIRS, where to find the headers
#   JSON_FOUND, if false, do not try to link against
#

set(BUILD_DEPS_DIR ${CMAKE_SOURCE_DIR}/${PROJECT_DEPS_DIR})
set(JSON_DEPS_DIR json)

find_path(
    JSON_INCLUDE_DIR NAMES json.hpp
    PATHS ${BUILD_DEPS_DIR}/${JSON_DEPS_DIR}/src
    NO_DEFAULT_PATH
)

include(FindPackageHandleStandardArgs)

find_package_handle_standard_args(
    Json
    FOUND_VAR JSON_FOUND
    REQUIRED_VARS
        JSON_INCLUDE_DIR
)

if(JSON_FOUND)
    set(JSON_INCLUDE_DIRS ${JSON_INCLUDE_DIR})
endif(JSON_FOUND)

mark_as_advanced(JSON_INCLUDE_DIR)
