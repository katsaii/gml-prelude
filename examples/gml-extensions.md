# GML Extensions

This section covers brief examples of additional functions to simplify a couple of common patterns in GML.

## Cloning Arrays

`array_clone` is particularly useful for taking ownership of arrays outside of scripts, and should be much faster than the standard `array_copy` function.

```js
var a = [1, 2, 3];
var b = a;
var c = array_clone(a);

// a == b
// a != c
```

Because of the way gamemaker works, arrays are passed by reference, so variables `a` and `b` hold a reference to the same array, hence they are equal. This is not the case with `c`, since an entirely new array is created.

## Cloning Structs

`struct_clone` offers a way to clone anonymous structs. In some situations you may want to take ownership of a struct, and if your struct has many members you might find it tricky or tedious to translate them into the new struct. This function attempts to solve that.

```js
var a = { foo : 1, bar : 2 };
var b = a;
var c = struct_clone(a);

// a == b
// a != c
```

This function does not support structs created using constructor functions, or structs which contain methods.