# Monads

A monad can be described as the minimal amount of behaviour which can be used to override function composition, such that some additional operation is performed on the internal value. Luckily for us, GML has two primitive monadic data types; these are arrays (lists) and `undefined`, which acts as a nullable data type. Hence, we can produce a monad over the elements of "lists of nullable values".

Values which are not arrays are assumed to be singleton lists.

## Bind

The `bind(mx, f)` function is the most important function of them all. It applies some function `f` to the middle values of `mx`. Take the following example

```js
function increment(_x) {
	return _x + 1;
}

var two = bind(1, increment);            // holds 2
var none = bind(undefined, increment);   // holds undefined
var array = bind([5, 6, 7], increment);  // holds [6, 7, 8]
var empty = bind([], increment);         // holds []
```

Notice that when the input is `undefined` or the empty array `[]`, the result doesn't change. This is what it is meant by the process of applying a function to the "middle values" of `mx`.

Additionally, if the function `f` returns an array, they are concatenated into the new return value. For example, interlacing an array of characters with their ASCII code becomes trivial:

```js
function ascii_pair(_x) {
	return [ord(_x), _x];
}

var array = bind(["A", "B", "C"], ascii_pair); // holds [65, "A", 66, "B", 67, "C"]
```