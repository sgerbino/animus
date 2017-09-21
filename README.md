# Animus

[![FreeBSD License](https://img.shields.io/:license-freebsd-red.svg)](https://github.com/sgerbino/animus/blob/master/LICENSE)
[![Build Status](https://travis-ci.org/sgerbino/animus.svg?branch=master)](https://travis-ci.org/sgerbino/animus)

Animus is a template CMake project that utilizes Djinni to generate Swift, Objective-C and Java bindings for modern C++. This is particularly useful for developing cross-platform mobile applications with common application logic.

The goal is this project is to provide:

- A core library template that can be used in the most native way for the IDE at hand
  - In Xcode, we build a framework with a modulemap included; This allows us to use the libraries created with a simple `import' statement, rather than requiring a bridging header
  - In Android Studio, we ensure that the CMake file can be consumed by Android Studio's gradle file out-of-the-box
- Support for out of source builds by default
- A modern CMake and C++ cross-platform implementation

## Table of contents

- [Quick start](#quick-start)
- [Usage](#usage)
- [Examples](#examples)
  - [Apple](#apple-example)
  - [Android](#android-example)
- [Directory structure](#directory-structure)
- [License](#license)

## Quick start

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
