# Iterators

Iterators are an extremely useful tool for iterating and generating values from arbitrary data structures through a common interface.

## Creating Iterators

This section covers the various ways to create iterators. Currently, the library contains built-in support for creating iterators from ranges, arrays, structs, generator functions, and common data structures.

For most intents and purposes, any iterator can be constructed simply using the `iterator` function, which inteligently decides which kind of iterator to create depending on the input argument(s). Alternatively, you may decide to use the many `iterator_from_*` functions to target a specific data structure, or use the `new Iterator(f)` to construct an iterator using a generator function `f`. Regardless, if you are unsure what data structure your variable holds, you should use the `iterator` function alone.

### Creating an Array Iterator

An array iterator can be created simply using the `iterator` function:

```js
var iter = iterator(["A", "B", "C", "D"]);
```

Alternatively, you can use `iterator_from_array` to specifically target arrays if you know your data structure will always be an array.

### Creating a Generator Function Iterator

To create an iterator from a function, you can use the `iterator` function:

```js
var iter = iterator(function() {
	return irandom(10);
});
```

This iterator isn't particularlly impressive since it will constantly return new random numbers. However, if you have a method which is bound a struct or object, this kind of approach can be useful.

Alternatively, you can use `iterator_from_method` to specifically target generator functions.

### Creating a Struct Iterator

There is a little more work to creating an iterator from a struct. Your struct must contain a `__next__` member which tells you the next item to return:

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

This approach is also compatible with structs created using constructor functions:

```js
function Vec3(_x, _y, _z) constructor {
	x = _x;
	y = _y;
	z = _z;
	__next__ = function() {
		static i = 0;
		i += 1;
		switch (i) {
		case 1:
			return x;
		case 2:
			return y;
		case 3:
			i = 0;
			return z;
		}
	}
}

var vec3 = new Vec3(3, 12, 0);
var iter = iterator(vec3);
```

This iterator will iterate over the three (`x`, `y`, and `z`) values of a `Vec3`.

### Finite Iterators

Some of the previous examples of iterators are infinite because they have no well-defined end state. To create an iterator which does end, you must return `undefined` in that case. As an example:

```js
var struct = {
	count : 0,
	__next__ : function() {
		count += 1;
		if (count <= 10) {
			return count;
		} else {
			// end of iterator
			return undefined;
		}
	}
}

var iter = iterator(struct);
```

This iterator only counts up to ten, since in the case that `count > 10`, the iterator returns `undefined`. This signals the end of the iterator.

### Ranges

A useful built-in iterator constructor is `iterator_range`. `iterator_range` will create a new (potentially infinite) iterator over the supplied range. For example, `iterator_range(1, 10)` will return a new iterator which generates values `1` to `10` *inclusive*.

## Basic Iterator Use

This section details basic operations you can perform on iterators to generate values.

### One at a Time

Once you have an iterator, you can start generating values using `Next` and `Peek`.

The `Next` method will return the next generated value and advance the iterator:

```js
var iter = iterator(["A", "B", "C", "D"]);

var a = iter.Next(); // holds "A"
var b = iter.Next(); // holds "B"
var c = iter.Next(); // holds "C"
```

The `Peek` function will return the next generated value, but will not advance the iterator.

```js
var iter = iterator(["A", "B", "C", "D"]);

var a_peeked = iter.Peek(); // holds "A"
var a = iter.Next();        // holds "A"
var b = iter.Next();        // holds "B"
```

### Many at Once

Other important operations include `Take` and `Drop`.

The `Take` method accepts a number `n` as an argument, and will generate `n`-many values and insert them into an array:

```js
var iter = iterator_range(1, 5);

var array = iter.Take(3); // holds [1, 2, 3]
```

The `Drop` method takes a number `n` as an argument, and will skip that number of generated values:

```js
var iter = iterator_range(2, 8);

iter.Drop(2);             // drops [2, 3]
var array = iter.Take(3); // holds [4, 5, 6]
```

### Collecting Iterators

If you require your iterator to be converted into a collection, such as an array or a ds_list, then this is possible with the `Collect` method. To collect an iterator into an array, simply call the method out-right:

```js
var iter = iterator_range(1, 5);

var array = iter.Collect(); // holds [1, 2, 3, 4, 5]
```

Howeverm, if you want to convert the iterator into an alternative data structure, such as a ds_list or a ds_stack, you should pass the `ds_type_` as a parameter. For example, to collect an iterator into a stack:

```js
var iter = iterator(["A", "B", "C"]);

var stack = iter.Collect(ds_type_stack);
```

Currently, the only supported built-in collections are: arrays, `ds_type_list`, `ds_type_queue`, and `ds_type_stack`.

### Converting an Iterator to a String

If you need to an easy way to display the contents of an iterator, then you can use the `toString` method:

```js
var iter = iterator_range(1, 3);

var str = iter.toString(); // holds "[1, 2, 3]"
```

Alternatively, you can use the built-in `string` function directly:

```js
var iter = iterator_range(1, 3);

var str = string(iter); // holds "[1, 2, 3]"
```

## Advanced Iterator Use

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