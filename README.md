# gml-prelude

This repository contains the sorce code for `gml-prelude`, a collection of functional programming features for [GameMaker Studio 2](https://www.yoyogames.com/gamemaker).

## Features

This library currently supports a range of functional programming methods, as well as some simple usability scripts. The full list of features is as follows:

 - Array and struct usability operations, such as `foreach` and `mapf`
 - Passing around and calling built-in function pointers
 - Function composition
 - Curried functions
 - Operator sections*
 - Iterators

*Though, not exactly. Curried functions exist as wrappers for operators. "Real" operator sections cannot exist.

## Getting Started

### Downloads

There will eventually be pre-compiled scripts available under the [releases](https://github.com/NuxiiGit/gml-prelude/releases) page.

Alternatively, the script files relating to the project can be found in the `scripts` directory; any `.gml` file prefixed with `prelude_` are the files you want to use.

## Usage examples

### Array and Struct Extensions

The library includes very basic extensions for arrays and structs. Examples include `array_clone` and `struct_clone`, `array_foreach` and `struct_foreach`, and `array_mapf`.

As an example, the `array_foreach` function takes a function and an array as parameters, and then calls that function for every element of the array:

```js
var source = [1, 2, 3, 4];
var dest = array_foreach(function(_x) {
	return _x + 1;
}, source);

// dest == [2, 3, 4, 5]
```

This code will add one to all elements in the source array and insert them into a new array stored in the variable `dest`.

### Getting Built-In Function Pointers

GameMaker has two kinds of callable objects: functions and methods. Usually, functions cannot be assigned to variables and called remotely without a lot of work. To get around this problem, and to treat functions as though they are methods, we can bind it to the calling object using `method(undefined, function_name)`, like so:

```js
var remote_show_message = method(undefined, show_message);

remote_show_message("It's alive!"); // called remotely
```

Here I assign the function `show_message` to a method, and then call it later.

This functionality has been bundled with this library under the name `func_ptr`.

### Currying

Currying is the process of passing arguments individually to a function. This allows you to create domain specific variants of a function by only passing the first couple of arguments before-hand. For example, let's say you have a script which draws your player sprite:

```js
function draw_player(_x, _y, _xscale, _yscale, _rot, _colour, _alpha) {
	draw_sprite_ext(spr_player, 0, _x, _y, _xscale, _yscale, _rot, _colour, _alpha);
}
```

Doesn't it look like a pain having to type out all those additional arguments when you only really care about the first two? Wouldn't it be nice if you could just pass the first two arguments without caring about what the remaining arguments are? Well, with currying this is possible!

To create the new `draw_player` script, the `curry` function can be used:

```js
draw_player = curry(2, func_ptr(draw_sprite_ext))(spr_player)(0);
```

The first argument of `curry` is the number of arguments you want to "curry"; in this case, two (the first two). The second argument is the function you actually want to curry; in this case it is the function `draw_sprite_ext`. Then, the `curry` function returns a method with the number of arguments you supplied curried. The resulting method is assigned to the instance variable `draw_player`, and can be used like any typical function would be, except the first two arguments have been partially applied.

```js
draw_player(x, y, image_xscale, image_yscale, image_angle, image_blend, image_alpha);
```

#### Operator Sections

Operator sections allow for operators to be used as predicates in higher order functions without the hassle of writing a new function manually. For example, the following expression:

```js
array_mapf(function(_x) { return _x * 2; }, [1, 2, 3]);
```

Can be replaced with:

```js
array_mapf(op_product(2), [1, 2, 3]);
```

This is because `op_product` returns a method which multiplies any argument it is given by `2`:

```js
var double = op_product(2);

show_message(double(4)) // prints "8", since 4 * 2 = 8
```

### Iterators

Iterators are extremely useful for having a common interface which can be expanded to any data structure.

There is currently built-in support for creating iterators from arrays, structs, and generator functions. Alternative data structures, such as ds_list/map/stack/queue and buffers are not natively supported, but are able to be written simply.

#### Creating an Array Iterator

The function `iterator` takes a data structure and converts it into an iterator.

```js
var iter = iterator(["A", "B", "C", "D"]);
```

In this case the data structure is an array, but it can also be used with functions and structs.

#### Creating a Generator Function Iterator

To create an iterator from a function, you would do:

```js
var iter = iterator(function() {
	return irandom(10);
});
```

This iterator isn't particularlly impressive, and will constantly return new random numbers. However, if you have an existing function which is bound to a struct or object, this kind of approach can be useful.

#### Creating a Struct Iterator

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

#### Creating Finite Iterators

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

#### Ranges

A useful built-in iterator constructor is `range`. `range` will create a new (potentially infinite) iterator over the supplied range. For example, `range(1, 10)` will return a new iterator which generates values `1` to `10` *inclusive*.

#### Basic Iterator Use

Once you have an iterator, you can start generating values using `peek` and `next`. The `peek` function will return the next generated value, but will not advance the iterator; the `next` function will return the next generated value and will advance the iterator.

```js
var iter = iterator(["A", "B", "C", "D"]);

var a_peeked = peek(iter); // holds "A"
var a = next(iter);        // holds "A"
var b = next(iter);        // holds "B"
```

Other important operations include `drop` and `take`. The `drop` function takes a number as an argument, and will skip that number of generated values. The `take` function takes a number as an argument, and will generate that number of values and insert them into an array.

```js
var iter = range(1, 5);

drop(1, iter);             // drop 1
var array = take(3, iter); // take [2, 3, 4]
```

`array` now holds an array of 3 values `[2, 3, 4]`, since the first generated value was dropped and the final element of the range is never used.