cmake_minimum_required(VERSION 3.6)
project(Animus VERSION 1.0.0.0)

set(DESCRIPTION "An application core with bindings for Swift and Java")
set(AUTHOR "Steve Gerbino")
set(EMAIL steve@gerbino.co)
set(YEAR 2017)
set(IDENTIFIER io.github.animus)

set(CPP_SOURCES 
      api.cpp
      api.hpp
      task_runner.hpp
      http.hpp
      http.cpp
      event_loop.hpp
      event_loop.cpp)

set(OBJC_SOURCES )
set(JAVA_SOURCES )

include(cmake/include/Animus.cmake)
