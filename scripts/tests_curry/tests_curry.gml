/* Tests currying of functions
 * Kat @Katsaii
 */

var prod = function(_a, _b) {
	return _a * _b;
}

var prod_partial = curry(prod, 2);

assert_eq(prod(2, 3), prod_partial(3));

var dot = function(_a, _b, _c, _d) {
	return dot_product(_a, _b, _c, _d);
}

var dot_partial = curry(dot, 2, 3);

assert_eq(dot(2, 3, 8, 12), dot_partial(8, 12));
assert_eq(dot(2, 3, 7, 12), dot_partial(7, 12));

var custom_print = function(_a, _b, _c) {
	return string(_a) + "izzard the " + string(_b) + " said " + string(_c);
}

var print_partial = curry(custom_print, "mega");

assert_eq(print_partial("brave", "James"), curry(print_partial, "brave")("James"));