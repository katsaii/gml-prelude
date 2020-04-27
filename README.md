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

## Usage examples

### Iterators

Iterators are extremely useful for having a common interface which can be expanded to any data structure.

There is current built-in support for creating iterators from arrays, structs, and generator functions. Alternative data structures, such as ds_list/map/stack/queue and buffers are not natively supported, but are able to be written simply.

#### Creating an Array Iterator

The function `iterator` takes a data structure and converts it into an iterator.

```js
var iter = iterator(["A", "B", "C", "D"]);
```

In this case the data structure is an array, but it can also be used with functions and structs.

To create an iterator from a function, you would do:

```js
var iter = iterator(function() {
	return irandom(10);
});
```

This iterator isn't particularlly impressive, and will constantly return new random numbers. However, if you have an existing function which is bound to a struct or object, this kind of approach can be useful.

Creating an iterator from a struct is a little more effort. Your struct must contain a `__next__` member which tells you the next item to return.

```js
var struct = {
	count : 0,
	__next__ : function() {
		count += 1;
		return count;
	}
}

var iter = iterator(struct);
```

This iterator is a little more impressive, because it will count up from 1.

Unfortunately, both of the previous iterators are infinite because they have no well-defined end. To create an iterator which ends, you must return `undefined` in that case. For example, an iterator which only counts up to ten would look like this:

```js
var struct = {
	count : 0,
	__next__ : function() {
		count += 1;
		if (count < 10) {
			return count;
		} else {
			// end of iterator
			return undefined;
		}
	}
}

var iter = iterator(struct);
```

### Ranges

A useful built-in iterator constructor is `range`. `range` will create a new (potentially infinite) iterator over the supplied range. For example, `range(1, 10)` will return a new iterator which generates values `1` to `10` *inclusive*.

### Basic Iterator Use

Once you have an iterator, you can start generating values using `peek` and `next`. The `peek` function will return the next generated value, but will not advance the iterator; the `next` function will return the next generated value and will advance the iterator.

```js
var iter = iterator(["A", "B", "C", "D"]);

var a_peeked = peek(iter);
var a = next(iter);
var b = next(iter);
```

`a_peeked` and `a` will both hold the same generated value, `"A"`, whereas `b` will hold the next generated value, `"B"`.

Other important operations include `drop` and `take`. The `drop` function takes a number as an argument, and will skip that number of generated values. The `take` function takes a number as an argument, and will generate that number of values and insert them into an array.

```js
var iter = range(1, 5);

drop(1, iter);
var arr = take(3, iter);
```

`arr` now holds an array of 3 values `[2, 3, 4]`, since the first generated value was dropped and the final element of the range was never used.

### Currying

### Using Built-In Functions

### Array and Struct Extensions

## Getting Started

### Downloads

There will eventually be pre-compiled scripts available under the [releases](https://github.com/NuxiiGit/gml-prelude/releases) page.

Alternatively, the script files relating to the project can be found in the `scripts` directory; any `.gml` file prefixed with `prelude_` are the files you want to use.