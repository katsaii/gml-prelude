# Monads

A monad can be described as the minimal amount of behaviour which can be used to override function composition, such that some additional operation is performed on the internal value. Luckily for us, GML has two primitive monadic data types; these are arrays (lists) and `undefined`, which acts as a nullable data type. Hence, we can produce a monad over the elements of "lists of nullable values".

Values which are not arrays are assumed to be singleton lists.

## Bind

The `bind(mx, f)` function is the most important function of them all. It applies some function `f` to the middle values of `mx`. Take the following example

```js
function increment(_x) {
	return _x + 1;
}

var two = bind(1, increment);              // holds 2
var nothing = bind(undefined, increment);  // holds undefined
var array = bind([5, 6, 7], increment);    // holds [6, 7, 8]
var empty = bind([], increment);           // holds []
```

Notice that when the input is `undefined` or the empty array `[]`, the result doesn't change. This is what it is meant by the process of applying a function to the "middle values" of `mx`.

Additionally, if the function `f` returns an array, they are concatenated into the new return value. For example, interlacing an array of characters with their ASCII code becomes trivial:

```js
function ascii_pair(_x) {
	return [ord(_x), _x];
}

var array = bind(["A", "B", "C"], ascii_pair); // holds [65, "A", 66, "B", 67, "C"]
```

## Join

The `join(mmx)` function gives you the benefit of collapsing arrays without having to pass in your own function. This is functionally identical to `bind(mmx, identity)` where `identity` is the identity map.

```js
var collapsed = join(["A", [1, undefined], [12]]); // collapses into ["A", 1, undefined, 12]
```

## Apply

The `apply(mf, mx)` function takes a step-up from the `bind` function, since it allows you to bind an impure function to an impure value. In the case of this library, this means that an array of functions can be called onto an array of values!

```js
function prod_by_four(_x) {
	return 4 * _x;
}

var eight = apply(prod_by_four, 2);                      // holds 8
var nothing = apply(prod_by_four, undefined);            // holds undefined
var array = apply(prod_by_four, [-1, 2, undefined, 3]);  // holds [-4, 8, undefined, 12]
```

Specifically, this function models the behaviour of [applicative functors](http://learnyouahaskell.com/functors-applicative-functors-and-monoids#applicative-functors).