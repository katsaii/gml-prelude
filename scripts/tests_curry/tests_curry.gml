/* Tests currying of functions
 * Kat @Katsaii
 */

// tests currying purity (no mutable state between the same partial function)
var dot = function(_a, _b, _c, _d) {
	return dot_product(_a, _b, _c, _d);
}
var dot_partial = partial(dot, 2, 3);
assert_eq(dot(2, 3, 8, 12), dot_partial(8, 12));
assert_eq(dot(2, 3, 7, 12), dot_partial(7, 12));

// tests basic currying
var prod = function(_a, _b) {
	return _a * _b;
}
var prod_partial = partial(prod, 2);
assert_eq(prod(2, 3), prod_partial(3));

// tests currying a curried function
var custom_print = function(_a, _b, _c) {
	return string(_a) + "izzard the " + string(_b) + " said " + string(_c);
}
var print_partial = partial(custom_print, "mega");
assert_eq(print_partial("brave", "James"), partial(print_partial, "brave")("James"));