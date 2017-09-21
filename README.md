# Animus

[![FreeBSD License](https://img.shields.io/:license-freebsd-red.svg)](https://github.com/sgerbino/animus/blob/master/LICENSE)
[![Build Status](https://travis-ci.org/sgerbino/animus.svg?branch=master)](https://travis-ci.org/sgerbino/animus)
<!--
 [![Build Status](https://ci.appveyor.com/api/projects/status/g719foxpitcnas2s/branch/master?svg=true)](https://ci.appveyor.com/project/sgerbino/table)
 [![Coverity Status](https://scan.coverity.com/projects/7249/badge.svg)](https://scan.coverity.com/projects/sgerbino-table)
-->

## Table of contents

- [Summary](#summary)
- [Usage](#usage)
- [Examples](#examples)
  - [Apple](#apple-example)
  - [Android](#android-example)
- [Directory structure](#directory-structure)
- [License](#license)

## Summary

Animus is a template CMake project that utilizes Djinni to generate Swift, Objective-C and Java bindings for modern C++. This is particularly useful for developing cross-platform mobile applications with common application logic.

```bash
git clone https://github.com/sgerbino/animus.git
git submodule update --init --recursive
mkdir build
cd build
cmake .. -G Xcode
```

## Usage

Define your core application interface in ```$PROJECT_SOURCE_DIR/rc/djinni/interface_definition.djinni``` and implement your interface in C++ in ```$PROJECT_SOURCE_DIR/src/cpp```.

### Android

To use an animus based project in Android Studio, open your Android project ```build.gradle``` and add the following snippets to the necessary sections.

```
android {
    defaultConfig {
        externalNativeBuild {
            cmake {
                cppFlags "-std=c++14 -fexceptions"
                arguments "-DANDROID_STL=c++_static"
            }
        }
    }
    externalNativeBuild {
        cmake {
            path "deps/animus/CMakeLists.txt"
        }
    }
}
```

## Examples

### Apple example

After building the project on macOS, a framework will be generated. Including this in a project will allow you to use your core API from Objective-C and/or Swift.

```
import Animus
...
var api = Api.createApi(AppleEventLoop(), httpClient: AppleHttp(), threadLauncher: AppleThreadLauncher())
```
*macOS Swift Example*

### Android example

*Coming soon*

## Directory structure

```bash
├── cmake/ # contains animus CMake modules
├── deps/ # third party dependencies
├── rc/ # resources folder
├── src/ # contains hand-written source files in Objective-C, C++, and Java
├── .travis.yml # defines Travis-CI automated builds and regression tests
└── CMakeLists.txt # the top-level CMake build file
```

## License

This project uses the "FreeBSD License" or "Simplified BSD License" making it
compatible with both commercial software licenses and the GNU/GPL. For more
information see [LICENSE](https://github.com/sgerbino/animus/blob/master/LICENSE).
