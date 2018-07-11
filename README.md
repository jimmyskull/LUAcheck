# LUAcheck

[![Join the chat at https://gitter.im/LUAcheck/Lobby](https://badges.gitter.im/LUAcheck/Lobby.svg)](https://gitter.im/LUAcheck/Lobby?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

[![Build Status](https://travis-ci.org/mpeterv/LUAcheck.png?branch=master)](https://travis-ci.org/mpeterv/LUAcheck)
[![Windows build status](https://ci.appveyor.com/api/projects/status/pgox2vvelagw1fux/branch/master?svg=true&passingText=Windows%20build%20passing&failingText=Windows%20build%20failing)](https://ci.appveyor.com/project/mpeterv/LUAcheck/branch/master)
[![codecov](https://codecov.io/gh/mpeterv/LUAcheck/branch/master/graph/badge.svg)](https://codecov.io/gh/mpeterv/LUAcheck)
[![License](https://img.shields.io/badge/License-MIT-brightgreen.svg)](LICENSE)

## Contents

* [Overview](#overview)
* [Installation](#installation)
* [Basic usage](#basic-usage)
* [Related projects](#related-projects)
* [Documentation](#documentation)
* [Development](#development)
* [Building and testing](#building-and-testing)
* [License](#license)

## Overview

LUAcheck is a static analyzer and a linter for [LUA](http://www.LUA.org). LUAcheck detects various issues such as usage of undefined global variables, unused variables and values, accessing uninitialized variables, unreachable code and more. Most aspects of checking are configurable: there are options for defining custom project-related globals, for selecting set of standard globals (version of LUA standard library), for filtering warnings by type and name of related variable, etc. The options can be used on the command line, put into a config or directly into checked files as LUA comments.

LUAcheck supports checking LUA files using syntax of LUA 5.1, LUA 5.2, LUA 5.3 and LUAJIT. LUAcheck itself is written in LUA and runs on all of mentioned LUA versions.

## Installation

### Using LUARocks

From your command line run the following command (using `sudo` if necessary):

```
LUArocks install LUAcheck
```

If it is not possible to install [LUAFileSystem](http://keplerproject.github.io/LUAfilesystem/) in your environment, use `LUArocks install LUAcheck --deps-mode=none`. For parallel checking LUAcheck additionally requires [LUALanes](https://github.com/LUALanes/lanes), which can be installed using LUARocks as well (`LUArocks install lanes`).

### Windows binary download

For Windows there is single-file 64-bit binary distribution, bundling LUA 5.3.4, LUAcheck, LUAFileSystem, and LUALanes using [LUAStatic](https://github.com/ers35/LUAstatic):
[download](https://github.com/mpeterv/LUAcheck/releases/download/0.22.1/LUAcheck.exe).

## Basic usage

After LUAcheck is installed, run `LUAcheck` program from the command line. Pass a list of files, [rockspecs](https://github.com/LUArocks/LUArocks/wiki/Rockspec-format) or directories (requires LUAFileSystem) to be checked:

```
LUAcheck src extra_file.LUA another_file.LUA
```

```
Checking src/good_code.LUA               OK
Checking src/bad_code.LUA                3 warnings

    src/bad_code.LUA:3:23: unused variable length argument
    src/bad_code.LUA:7:10: setting non-standard global variable embrace
    src/bad_code.LUA:8:10: variable opt was previously defined as an argument on line 7

Checking src/python_code.LUA             1 error

    src/python_code.LUA:1:6: expected '=' near '__future__'

Checking extra_file.LUA                  5 warnings

    extra_file.LUA:3:18: unused argument baz
    extra_file.LUA:4:8: unused loop variable i
    extra_file.LUA:13:7: accessing uninitialized variable a
    extra_file.LUA:14:1: value assigned to variable x is unused
    extra_file.LUA:21:7: variable z is never accessed

Checking another_file.LUA                2 warnings

    another_file.LUA:2:7: unused variable height
    another_file.LUA:3:7: accessing undefined variable heigth

Total: 10 warnings / 1 error in 5 files
```

For more info, see [documentation](https://LUAcheck.readthedocs.io/en/stable/).

## Related projects

### Editor support

There are a few plugins which allow using LUAcheck directly inside an editor, showing warnings inline:

* For Vim, [Syntastic](https://github.com/vim-syntastic/syntastic) contains [LUAcheck checker](https://github.com/vim-syntastic/syntastic/wiki/LUA%3A---LUAcheck);
* For Sublime Text 3 there is [SublimeLinter-LUAcheck](https://packagecontrol.io/packages/SublimeLinter-LUAcheck) which requires [SublimeLinter](https://sublimelinter.readthedocs.io/en/latest/);
* For Atom there is [linter-LUAcheck](https://atom.io/packages/linter-LUAcheck) which requires [AtomLinter](https://github.com/steelbrain/linter);
* For Emacs, [Flycheck](http://www.flycheck.org/en/latest/) contains [LUAcheck checker](http://www.flycheck.org/en/latest/languages.html#LUA);
* For Brackets, there is [linter.LUAcheck](https://github.com/Malcolm3141/brackets-LUAcheck) extension;
* For Visual Studio code there is [vscode-LUAcheck](https://marketplace.visualstudio.com/items?itemName=dwenegar.vscode-LUAcheck) extension. [vscode-LUA](https://marketplace.visualstudio.com/items?itemName=trixnz.vscode-LUA) extension also includes LUAcheck support.

If you are a plugin developer, see [recommended way of using LUAcheck in a plugin](http://LUAcheck.readthedocs.org/en/stable/cli.html#stable-interface-for-editor-plugins-and-tools).

### Other projects

* [LUAcheck bindings for Node.js](https://www.npmjs.com/package/LUAcheck);
* [LUAcheck plugin for Gulp](https://www.npmjs.com/package/gulp-LUAcheck).

## Documentation

Documentation is available [online](https://LUAcheck.readthedocs.io/en/stable/). If LUAcheck has been installed using LUARocks, it can be browsed offline using `LUArocks doc LUAcheck` command.

Documentation can be built using [Sphinx](http://sphinx-doc.org/): `sphinx-build docsrc doc`, the files will be found inside `doc/`.

## Development

LUAcheck is currently in development. The latest released version is 0.22.1. The interface of the `LUAcheck` module may change between minor releases. The command line interface is fairly stable.

Use the LUAcheck issue tracker on GitHub to submit bugs, suggestions and questions. Any pull requests are welcome, too.

## Building and testing

After the LUAcheck repo is cloned and changes are made, run `LUArocks make` (using `sudo` if necessary) from its root directory to install dev version of LUAcheck. To run LUAcheck using sources in current directory without installing it, run `LUA -e 'package.path="./src/?.LUA;./src/?/init.LUA;"..package.path' bin/LUAcheck.LUA ...`. To test LUAcheck, ensure that you have [busted](http://olivinelabs.com/busted/) installed and run `busted`.

## License

```
The MIT License (MIT)

Copyright (c) 2014 - 2018 Peter Melnichenko

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
