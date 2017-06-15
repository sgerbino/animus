set(BUILD_DEPS_DIR ${PROJECT_SOURCE_DIR}/${ANIMUS_DEPS_DIR})
set(DJINNI_DEPS_DIR djinni)

find_path(
    DJINNI_EXECUTABLE_DIR NAMES run-assume-built
    PATHS ${BUILD_DEPS_DIR}/${DJINNI_DEPS_DIR}/src
    NO_DEFAULT_PATH
)

find_path(
    DJINNI_JNI_INCLUDE_DIR NAMES djinni_support.hpp
    PATHS ${BUILD_DEPS_DIR}/${DJINNI_DEPS_DIR}/support-lib/jni
    NO_DEFAULT_PATH
)

find_path(
    DJINNI_OBJC_INCLUDE_DIR NAMES DJIError.h
    PATHS ${BUILD_DEPS_DIR}/${DJINNI_DEPS_DIR}/support-lib/objc
    NO_DEFAULT_PATH
)

include(FindPackageHandleStandardArgs)

find_package_handle_standard_args(
    Djinni
    FOUND_VAR DJINNI_FOUND
    REQUIRED_VARS
        DJINNI_JNI_INCLUDE_DIR
        DJINNI_OBJC_INCLUDE_DIR
)

if(DJINNI_FOUND)
    find_program(
	     DJINNI_EXECUTABLE
	     run-assume-built
	     PATHS ${DJINNI_EXECUTABLE_DIR}
    )
endif(DJINNI_FOUND)

mark_as_advanced(DJINNI_INCLUDE_DIR)
