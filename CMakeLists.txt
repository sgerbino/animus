cmake_minimum_required(VERSION 3.6)
include("cmake/include/HunterGate.cmake")
HunterGate(
  URL "https://github.com/ruslo/hunter/archive/v0.19.144.tar.gz"
  SHA1 "e3efd470f8b60468db8730eac8c04792f77fe1b1"
)
project(Animus VERSION 1.0.0.0)

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

set(JAVA_SOURCES )

include(cmake/include/Animus.cmake)
