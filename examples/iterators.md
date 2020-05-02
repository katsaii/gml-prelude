# Iterators

Iterators are an extremely useful tool for iterating and generating values from arbitrary data structures through a common interface.

## Creating Iterators

This section covers the various ways to create iterators. Currently, the library contains built-in support for creating iterators from ranges, arrays, structs, generator functions, and common data structures.

For most intents and purposes, any iterator can be constructed simply using the `iterator` function, which inteligently decides which kind of iterator to create depending on the input argument(s). Alternatively, you may decide to use the many `iterator_from_*` functions to target a specific data structure, or use the `new Iterator(f)` to construct an iterator using a generator function `f`.

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