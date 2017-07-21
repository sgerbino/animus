# Animus

[![FreeBSD License](https://img.shields.io/:license-freebsd-red.svg)](https://github.com/sgerbino/table/blob/master/COPYING.txt)
<!--
 [![Build Status](https://travis-ci.org/sgerbino/table.svg?branch=master)](https://travis-ci.org/sgerbino/table)
 [![Build Status](https://ci.appveyor.com/api/projects/status/g719foxpitcnas2s/branch/master?svg=true)](https://ci.appveyor.com/project/sgerbino/table)
 [![Coverity Status](https://scan.coverity.com/projects/7249/badge.svg)](https://scan.coverity.com/projects/sgerbino-table)
 -->

## Table of contents

- [Summary](#summary)
- [Usage](#usage)
- [Examples](#examples)
- [License](#license)

## Summary

Animus is a template CMake project that utilizes Djinni to generate Objective-C and Java bindings for modern C++. This is particularly useful for developing cross-platform mobile applications with common application logic.

```bash
mkdir build
cd build
cmake .. -G Xcode
```

## Usage

Define your core application interface in ```$PROJECT_SOURCE_DIR/rc/djinni/interface_definition.djinni``` and implement your interface in C++ in ```$PROJECT_SOURCE_DIR/src```.

## Examples

### Apple

After building the project on macOS, a framework will be generated. Including this in a project will allow you to use your core API from Objective-C and/or Swift.

```
var api = Api.createApi("Animus",
   uiThread: AppleEventLoop(),
   httpImpl: AppleHttp(),
   launcher: AppleThreadLauncher())
```
*macOS Swift Example*

## License

This project uses the "FreeBSD License" or "Simplified BSD License" making it
compatible with both commercial software licenses and the GNU/GPL. For more
information see [LICENSE](https://github.com/sgerbino/table/blob/master/LICENSE).
