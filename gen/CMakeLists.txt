if (${PROJECT_WITH_JNI})
   add_subdirectory(jni)
endif()

if (${PROJECT_WITH_OBJC})
   add_subdirectory(objc)
endif()

