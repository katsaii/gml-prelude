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

### Getting Built-In Function Pointers

Built-in functions have usually always been unable to be assigned to variables and called remotely. To get around this, a neat hack can be used: binding a built-in function to an empty struct allows you to use it as a method.

```js
var my_show_message = method({}, show_message);

my_show_message("it's alive!");
```

This behaviour has been wrapped up and offered with this library under the function `func_ptr`. This lets you do some very powerful things, such as folding iterators into built-in data structures.

```js
var arr = ["A", "B", "C"];
var iter = flatten(enumerate(iterator(arr)));
var list = fold(func_ptr(ds_list_add),    ds_list_create(), iter);
                   // or ds_stack_push    ds_stack_create
                   //    ds_queue_enqueue ds_queue_create
                   //    etc.

/* list[| 0] == 0
 * list[| 1] == "A"
 * list[| 2] == 1
 * list[| 3] == "B"
 * list[| 4] == 2
 * list[| 5] == "C"
 */
```

A more detailed explaination of this code can be found in the iterator examples.

#### Operator Sections

### Iterators

Iterators are extremely useful for having a common interface which can be expanded to any data structure.

There is current built-in support for creating iterators from arrays, structs, and generator functions. Alternative data structures, such as ds_list/map/stack/queue and buffers are not natively supported, but are able to be written simply.

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

Currying is the process of passing arguments individually to a function. This allows you to create domain specific variants of a function by only passing the first couple of arguments before-hand. For example, let's say you have a script which draws your player sprite:

```js
function draw_player(_x, _y, _xscale, _yscale, _rot, _colour, _alpha) {
	draw_sprite_ext(spr_player, 0, _x, _y, _xscale, _yscale, _rot, _colour, _alpha);
}
```

Doesn't it look like a pain having to type out all those additional arguments when you only care about the first two? Wouldn't it be nice if you could just pass the first two arguments without caring about what the remaining arguments are? Well, with currying this is possible!

To create the new `draw_player` script, the `curry` function can be used:

```js
draw_player = curry(2, func_ptr(draw_sprite_ext))(spr_player)(0);
```

The first argument of `curry` is the number of arguments you want to "curry"; in this case, two (the first two). The second argument is the function you actually want to curry; in this case it is a pointer to a built-in function. The `curry` function then returns a new function with the number of arguments you supplied curried, and this is where the sprite (`spr_player`) and the image index (`0`) are passed *individually*. The resulting function is now assigned to the instance variable `draw_player`, and can be used like any typical function would be, except the first two arguments are automatically subsituted.

```js
draw_player(x, y, image_xscale, image_yscale, image_angle, image_blend, image_alpha);
```

### Array and Struct Extensions

## Getting Started

### Downloads

There will eventually be pre-compiled scripts available under the [releases](https://github.com/NuxiiGit/gml-prelude/releases) page.

Alternatively, the script files relating to the project can be found in the `scripts` directory; any `.gml` file prefixed with `prelude_` are the files you want to use.