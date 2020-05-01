# gml-prelude

This repository contains the sorce code for `gml-prelude`, a collection of functional programming features for [GameMaker Studio 2](https://www.yoyogames.com/gamemaker).

## Features

This library currently supports a range of functional programming methods, as well as some simple usability scripts. The power of functional programming comes from the ability to express complex behaviour in a relatively simple way, by building off of previously defined behaviour.

One of the main features of this library are [iterators](https://github.com/NuxiiGit/gml-prelude/master/examples/iterators.md); the benefit of iterators comes from the ability to be lazy, and the ability to combine arbitrarily many operations together. This behaviour allows you to handle infinite data structures without stalling.

Another powerful feature is [partial application](https://github.com/NuxiiGit/gml-prelude/master/examples/partial-application.md) of function arguments. This helps reduce code duplication and verbosity.

## Usage examples

In depth examples can be found in the [examples](https://github.com/NuxiiGit/gml-prelude/master/examples/README.md) section.

## Getting Started

### Installing from Releases

To install a release from the [releases](https://github.com/NuxiiGit/gml-prelude/releases) page, simply unzip the archive file and insert the scripts into your project.

### Installing from the Project

To install directly from the project, locate the script files relating to the project under the `scripts` directory; any `.gml` file prefixed with `prelude_` are the files you want to use.