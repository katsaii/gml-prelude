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
