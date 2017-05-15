# This module defines:
#
# ::
#
#   JSON_INCLUDE_DIRS, where to find the headers
#   JSON_FOUND, if false, do not try to link against
#

set(BUILD_DEPS_DIR ${PROJECT_SOURCE_DIR}/${PROJECT_DEPS_DIR})
set(DJINNI_DEPS_DIR djinni)

find_path(
    DJINNI_INCLUDE_DIR NAMES run
    PATHS ${BUILD_DEPS_DIR}/${DJINNI_DEPS_DIR}/src
    NO_DEFAULT_PATH
)

include(FindPackageHandleStandardArgs)

find_package_handle_standard_args(
    Djinni
    FOUND_VAR DJINNI_FOUND
    REQUIRED_VARS
        DJINNI_INCLUDE_DIR
)

if(DJINNI_FOUND)
    set(DJINNI_INCLUDE_DIRS ${DJINNI_INCLUDE_DIR})
    find_program(
	DJINNI_EXECUTABLE
	run-assume-built
	PATHS ${DJINNI_INCLUDE_DIRS})
endif(DJINNI_FOUND)

mark_as_advanced(DJINNI_INCLUDE_DIR)
