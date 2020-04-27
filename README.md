# gml-prelude

This repository contains the sorce code for `gml-prelude`, a collection of functional programming features for [GameMaker Studio 2](https://www.yoyogames.com/gamemaker).

## Features

This library currently supports a range of functional programming methods, as well as some simple usability scripts. The full list of features is as follows:

 - Iterators
 - Curried functions
 - Operator sections*
 - Passing around and calling built-in function pointers
 - Identity function
 - Array and struct usability operations, such as `foreach` and `mapf`

*Though, not exactly. Curried functions exist as wrappers for operators. "Real" operator sections cannot exist.

## Getting Started

### Downloads

There will eventually be pre-compiled scripts available under the [releases](https://github.com/NuxiiGit/gml-prelude/releases) page.

Alternatively, the script files relating to the project can be found in the `scripts` directory; any `.gml` file prefixed with `prelude_` are the files you want to use.