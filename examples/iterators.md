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

### Iteration

The main idea of iterators is to help generalise iteration, right? This library contains two important methods for iterating through iterators called `ForEach` and `Fold`.

The `ForEach` method takes a procedure `f` as a parameter and calls it for every element of the iterator:

```js
var iter = iterator([1, "a", false]);

iter.ForEach(function(_x) {
	show_message(_x); // prints 1
	                  //        "a"
	                  //        false
});
```

Alternatively, the `Fold` method captures the concept of applying some binary operation to all elements of the iterator. Let's say you have an array of strings `["hello", " ", "world"]`. To concatenate these together we could use the `+` operator like so:

```js
var array = ["hello", " ", "world"];

var hello_world = array[0] + array[1] + array[2];
```

This idea of applying `+` over and over again is what fold achieves. Therefore, the previous section of code can be reduced to:

```js
var array = ["hello", " ", "world"];
var iter = iterator(array);

var hello_world = iter.Fold("", function(_left, _right) {
	return _left + _right;
});
```

Of course, this is a very basic case. But now imagine you have an array which is 100 values long, or an array which you don't know the size of, it becomes a lot trickier to add all items in that array together. That is why `Fold` is so useful; it abstracts away the boilerplate of `for` loops and accumulators.

## Advanced Iterator Use

This section picks up the pace, and details additional operations which can be used to modify and process iterators.

### Lazy Evaluation

As you might have noticed, unlike typical data structures, iterators can be infinite in size. This can make them very powerful for handling nested data structures and cyclic references.

All of this is achieved through lazy evaluation (also known as [call-by-need](https://en.wikipedia.org/wiki/Evaluation_strategy#Call_by_need)). This means that new values are only ever generated when they are absolutely required. If you only care about the first 10 elements of an infinite iterator, then the remaining values will never be created.

### Iterator Operations

Iterators can be stacked with multiple operations with barely any overhead or complexity from using raw arrays. Some examples of operations are `Zip`, `Map`, and `Concat`.

The `Zip` method takes a second iterator as an argument, and returns a new iterator which generate pairs of values that correspond to the generated values of each iterator:

```js
var a = iterator("hello");
var b = iterator("world");

var iter = a.Zip(b);

var array = iter.Collect(); // holds [["w", "h"], ["o", "e"], ["r", "l"], ["l", "l"], ["d", "o"]]
```

The `Map` method takes a function as an argument, and returns a new iterator which applies that function to each generated value of the previous iterator:

```js
var iter = iterator_range(1, infinity);
    iter = iter.Map(function(_x) { return _x * _x });

var array = iter.Take(4); // holds [1, 4, 9, 16]
```

The `Concat` method converts an iterator wich generates arrays into an iterator which also iterates over those arrays; that is, a two-dimensional array can be flattened into a single-dimensional array:

```js
var iter = iterator([["W", vk_up], ["A", vk_left], ["S", vk_down], ["D", vk_right]]);
    iter = iter.Concat();

var array = iter.Collect(); // holds ["W", vk_up, "A", vk_left, "S", vk_down, "D", vk_right]
```