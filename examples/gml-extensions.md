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