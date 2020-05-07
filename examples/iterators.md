# Iterators

Iterators are an extremely useful tool for iterating and generating values from arbitrary data structures through a common interface.

## Creating Iterators

This section covers the various ways to create iterators. Currently, the library contains built-in support for creating iterators from ranges, arrays, structs, strings, and common data structures.

To create an iterator, you should use the `Iterator` constructor function. Passing an array, struct, or string to this constructor will cause it to intelligently decide what sort of iterator you need.

### Creating an Array Iterator

An array iterator can be created simply using the `Iterator` constructor:

```js
var iter = new Iterator(["A", "B", "C", "D"]);
```

Alternatively, you can pass an instance of `ArrayReader` to specifically target arrays if you know your data structure will always be an array:

```js
var reader = new ArrayReader(["A", "B", "C", "D"]);
var iter = new Iterator(reader);
```

### Creating a String Iterator

Much like array iterators, you should create a string iterator by using the `Iterator` constructor:

```js
var iter = new Iterator("hello world");
```

This will create an iterator which generates individual characters of the string. This is the same as creating an iterator from an instance of the `CharacterReader` struct:

```js
var reader = new CharacterReader("hello world");
var iter = new Iterator(reader);
```

Alternatively, you can use a different string iterator by passing in an instance of the `WordReader` struct:

```js
var reader = new WordReader("hello world", " ");
var iter = new Iterator(reader);
```

This variant will produce an iterator which generates slices of a string separated by some delimiter; in this case, the delimiter was `" "`.

### Creating Iterators From Data Structures

Unfortunately, due to how data structures are implemented in GML, the `Iterator` constructor does not have enough information to correctly create an iterator from data structures. Therefore, you should also pass the `ds_type_*` of the data structure you intend to use:

```js
var list = ds_list_create();
ds_list_add(list, 1, 2, 3);
var iter = new Iterator(list, ds_type_list);
```

Alternatively, you can pass an instance of the corresponding reader struct. The following table details the `ds_type_*` and its corresponding reader struct:

<p align="center">

| Type               | Reader                |
|--------------------|-----------------------|
| `ds_type_grid`     | `GridReader`          |
| `ds_type_list`     | `ListReader`          |
| `ds_type_queue`    | `QueueReader`         |
| `ds_type_stack`    | `StackReader`         |
| `ds_type_priority` | `PriorityQueueReader` |
| `ds_type_map`      | `MapReader`           |

</p>

### Writing Custom Iterators Using Structs

There is a little more work to creating an iterator from a struct. Your struct must contain a `__next__` member which tells you the next item to return. The following iterator will count up from 1:

```js
var struct = {
	count : 0,
	__next__ : function() {
		count += 1;
		return count;
	}
}

var iter = new Iterator(struct);
```

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
var iter = new Iterator(vec3);
```

This iterator will iterate over the three (`x`, `y`, and `z`) values of a `Vec3`.

### Writing Finite Iterators

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

var iter = new Iterator(struct);
```

This iterator only counts up to ten, since in the case that `count > 10`, the iterator returns `undefined`. This signals the end of the iterator.

### Ranges

A useful built-in iterator constructor is `range`. The `range` function will create a new (potentially infinite) iterator over the supplied range. For example, `range(1, 10)` will return a new iterator which generates values `1` to `10` *inclusive*.

An additional, optional argument can be passed to the `range` function to decide the step of the range; that is, the value to increment each element of the range by. The default step is `1`.

### Creating a File Iterator

An auxiliary iterator which was included in this library was the file iterator. This iterator acts as a wrapper for the `file_text_*` functions, except it gives you the benefit of iterators. This iterator can be created by supplying an instance of the `FileReader` struct:

```js
var file = file_text_open("./test.txt");
var reader = new FileReader(file);
var iter = new Iterator(reader);
```

## Basic Iterator Use

This section details basic operations you can perform on iterators to generate values.

### One at a Time

Once you have an iterator, you can start generating values using `next` and `peek`.

#### Next

The `next` method will return the next generated value and advance the iterator:

```js
var iter = new Iterator(["A", "B", "C", "D"]);

var a = iter.next(); // holds "A"
var b = iter.next(); // holds "B"
var c = iter.next(); // holds "C"
```

#### Peek

The `peek` function will return the next generated value, but will not advance the iterator.

```js
var iter = new Iterator(["A", "B", "C", "D"]);

var a_peeked = iter.peek(); // holds "A"
var a = iter.next();        // holds "A"
var b = iter.next();        // holds "B"
```

### Many at Once

Other important operations include `take` and `drop`.

#### Take

The `take` method accepts a number `n` as an argument, and will generate `n`-many values and insert them into an array:

```js
var iter = range(1, 5);

var array = iter.take(3); // holds [1, 2, 3]
```

#### Drop

The `drop` method takes a number `n` as an argument, and will skip that number of generated values:

```js
var iter = range(2, 8);

iter.drop(2);             // drops [2, 3]
var array = iter.take(3); // holds [4, 5, 6]
```

### Collecting Iterators

If you require your iterator to be converted into a collection, such as an array or a ds_list, then this is possible with the `collect` method. To collect an iterator into an array, simply call the method out-right:

```js
var iter = range(1, 5);

var array = iter.collect(); // holds [1, 2, 3, 4, 5]
```

Howeverm, if you want to convert the iterator into an alternative data structure, such as a ds_list or a ds_stack, you should pass the `ds_type_` as a parameter. For example, to collect an iterator into a stack:

```js
var iter = new Iterator(["A", "B", "C"]);

var stack = iter.collect(ds_type_stack);
```

Currently, the only supported built-in collections are: arrays, `ds_type_list`, `ds_type_queue`, and `ds_type_stack`.

### Converting an Iterator to a String

If you need to an easy way to display the contents of an iterator, then you can use the `toString` method:

```js
var iter = range(1, 3);

var str = iter.toString(); // holds "[1, 2, 3]"
```

Alternatively, you can use the built-in `string` function directly:

```js
var iter = range(1, 3);

var str = string(iter); // holds "[1, 2, 3]"
```

### Iteration

The main idea of iterators is to help generalise iteration, right? This library contains two important methods for iterating through iterators called `forEach` and `fold`.

#### ForEach

The `forEach` method takes a procedure `f` as a parameter and calls it for every element of the iterator:

```js
var iter = new Iterator([1, "a", false]);

iter.forEach(function(_x) {
	show_message(_x); // prints 1
	                  //        "a"
	                  //        false
});
```

#### Fold

Alternatively, the `fold` method captures the concept of applying some binary operation to all elements of the iterator. Let's say you have an array of strings `["hello", " ", "world"]`. To concatenate these together we could use the `+` operator like so:

```js
var array = ["hello", " ", "world"];

var hello_world = array[0] + array[1] + array[2];
```

This idea of applying `+` over and over again is what fold achieves. Therefore, the previous section of code can be reduced to:

```js
var array = ["hello", " ", "world"];
var iter = new Iterator(array);

var hello_world = iter.fold("", function(_left, _right) {
	return _left + _right;
});
```

Of course, this is a very basic case. But now imagine you have an array which is 100 values long, or an array which you don't know the size of, it becomes a lot trickier to add all items in that array together. That is why `fold` is so useful; it abstracts away the boilerplate of `for` loops and accumulators.

## Advanced Iterator Use

This section picks up the pace, and details additional operations which can be used to modify and process iterators.

### Lazy Evaluation

As you might have noticed, unlike typical data structures, iterators can be infinite in size. This can make them very powerful for handling nested data structures and cyclic references.

All of this is achieved through lazy evaluation (also known as [call-by-need](https://en.wikipedia.org/wiki/Evaluation_strategy#Call_by_need)). This means that new values are only ever generated when they are absolutely required. If you only care about the first 10 elements of an infinite iterator, then the remaining values will never be created.

### Iterator Operations

Iterators can be stacked with multiple operations with barely any overhead or complexity from using raw arrays. Some examples of operations are `zip`, `map`, and `concat`.

#### Zip

The `zip` method takes a second iterator as an argument, and returns a new iterator which generate pairs of values that correspond to the generated values of each iterator:

```js
var a = new Iterator("hello");
var b = new Iterator("world");

var iter = a.zip(b);

var array = iter.collect(); // holds [["w", "h"], ["o", "e"], ["r", "l"], ["l", "l"], ["d", "o"]]
```

#### Map

The `map` method takes a function as an argument, and returns a new iterator which applies that function to each generated value of the previous iterator:

```js
var iter = range(1, infinity);
    iter = iter.map(function(_x) { return _x * _x });

var array = iter.take(4); // holds [1, 4, 9, 16]
```

#### Concat

The `concat` method converts an iterator wich generates arrays into an iterator which also iterates over those arrays; that is, a two-dimensional array can be flattened into a single-dimensional array:

```js
var iter = new Iterator([["W", vk_up], ["A", vk_left], ["S", vk_down], ["D", vk_right]]);
    iter = iter.concat();

var array = iter.collect(); // holds ["W", vk_up, "A", vk_left, "S", vk_down, "D", vk_right]
```

### Indexable Iterators

If your data structure has some internal state which determines "how far along" in the iteration it is, you might want to consider implementing a `__seek__` method. This method enables iterators which implement it to be indexed at arbitrary locations using the `seek` method, and even totally reset using the `reset` method. This is particularly useful if you would like to use the same iterator repetitively.

```js
var abc_reader = {
	n : 0,
	__next__ : function() {
		var char = chr(65 + n);
		n += 1;
		return char;
	},
	__seek__ : function(_pos) {
		n = _pos;
	}
}

var iter = new Iterator(abc_reader);
var a = iter.next();      // holds "A"
var b = iter.next();      // holds "B"
iter.seek(6);
var h = iter.next();      // holds "H"
var i = iter.next();      // holds "I"
iter.reset();
var also_a = iter.next(); // holds "A"
var also_b = iter.next(); // holds "B"
```