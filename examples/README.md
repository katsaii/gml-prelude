
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

### Function Composition

Function composition is the process of passing the output of one function as the input to another; that is, let `f(x) = y` and `g(y) = z` be functions, and their composition `gf` would be given by `g(f(x))`.

This library contains a simple function called `compose` to achieve this.

```js
var remote_string_upper = func_ptr(string_upper);
var remote_show_message = func_ptr(show_message);

var scream_message = compose(remote_show_message, remote_string_upper);

scream_message("hello world"); // prints "HELLO WORLD"
```

This code will compose the two functions `string_upper` and `show_message` into a new method which prints a message in ALL CAPS!!

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

Iterators are extremely useful for having a general interface for generating values from arbitrary data structures.

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

#### Advanced Iterator Use

This is where we pick up the pace.

Iterators can be stacked with multiple operations with barely any overhead and complexity from using raw arrays. Below I briefly showcase some examples.

*Interlacing two arrays, `a` and `b`:*

```js
var a = [ 1 ,  2 ,  3 ,  4 ,  5 ];
var b = ["A", "B", "C", "D", "E"];

var iter = zip(iterator(a), iterator(b));
var interlaced = iterate(iter);

// interlaced == [1, "A", 2, "B", 3, "C", 4, "D", 5, "E"]
```

*Filtering numbers inside a specific range:*

```js
var a = [-1, -1, 0, 1, 2, 2, 3, 4, 5, 6, 7, 9, 10, 10, 11];
var range_min = 3;
var range_max = 10;

var iter = filter(op_less(range_max),
		filter(op_greater(range_min), iterator(a)));
var ranged = iterate(iter);

// ranged == [3, 4, 5, 6, 7, 9, 10, 10]
```

*Interlacing an array of characters with their character codes, and then folding the iterator into a ds_list:*

```js
var arr = ["A", "B", "C"];

var iter = concat(mapf(function(_x) { return [ord(_x), _x]; }, iterator(arr)));
var list = fold(func_ptr(ds_list_add), ds_list_create(), iter);

/* list[| 0] == 65
 * list[| 1] == "A"
 * list[| 2] == 66
 * list[| 3] == "B"
 * list[| 4] == 67
 * list[| 5] == "C"
 */
```

Detailed information on these operations can be found in the source files of the library.