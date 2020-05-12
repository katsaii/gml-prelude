# Higher-Order Functions

This section details various higher-order functions and functional programming techniques which are supported for this library.

## Getting Built-In Function Pointers

GameMaker has two kinds of callable objects: functions and methods. Usually, functions cannot be assigned to variables and called remotely without a lot of work. To get around this problem, and to treat functions as though they are methods, we can bind it to the calling object by using `method(undefined, function_name)`.

```js
var remote_show_message = method(undefined, show_message);

remote_show_message("It's alive!"); // called remotely
```

Here I assign the function `show_message` to a method, and then call it later.

This functionality has been bundled with this library under the name of `func_ptr`. So, the previous segment of code can be reduced to:

```js
var remote_show_message = func_ptr(show_message);

remote_show_message("It's alive!"); // also called remotely
```

## Function Composition

Function composition is the process of passing the output of one function as the input to another; that is, if `f(x) = y` and `g(y) = z` are functions, then their composition `gf` would be given by `g(f(x))`.

This library contains a simple function called `compose` which can achieve this. The first argument is the function which will have the output of second argument fed into it; in other words, the first argument is `g` and the second argument is `f`.

```js
var remote_string_upper = func_ptr(string_upper);
var remote_show_message = func_ptr(show_message);

var scream_message = compose(remote_show_message, remote_string_upper);

scream_message("hello world"); // prints "HELLO WORLD"
```

This code will compose the two functions `string_upper` and `show_message` into a new method which prints a message in capital case.

## Partial Application and Currying

Currying is the concept of being able to pass arguments to a function either individually, or all at once. This allows you to create domain-specific variants of a function by only applying the first couple of arguments before-hand. For example, let's say you have a function which draws your player sprite:

```js
function draw_player(_x, _y, _xscale, _yscale, _rot, _colour, _alpha) {
	draw_sprite_ext(spr_player, 0, _x, _y, _xscale, _yscale, _rot, _colour, _alpha);
}
```

Doesn't it look like a pain having to type out all those additional arguments when you only really care about the first two? Wouldn't it be nice if you could just pass the first two arguments without caring about what the remaining arguments are? Well, with currying this is possible!

To create a the new `draw_player` function, the `partial` function can be used:

```js
draw_player = partial(draw_sprite_ext, spr_player, 0);
```

The first argument of `partial` is the function you want to partially apply. Next, any additional arguments are the arguments of the function you are partially applying. Finally, the `partial` function returns a method which contains those arguments applied to the function. The resulting method is assigned to the instance variable `draw_player`, and can be used like any typical function would be.

```js
draw_player(x, y, image_xscale, image_yscale, image_angle, image_blend, image_alpha);
```

## The Identity Function

The identity function is nothing special, and is simply a function which returns its input; that is, it is the case that `identity(x) == x` for all possible values `x`. This sort of function is actually fairly useful to define "no behaviour" in situations where a function is required. For example, perhaps you have a higher-order function which uses some function `f` to define or modify some `Enemy` struct. Using the identity function, you can just let the struct pass through without any modification.

## The No-Op Function

The `noop` function is similar to the `identity` function, except it does not accept any arguments and always returns `undefined`. This makes it functionally identical to `identity(undefined)`.