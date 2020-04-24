/* Tests currying of functions
 * Kat @Katsaii
 */

var prod = function(_a, _b) {
	return _a * _b;
}

var prod_curried = curry_pair(prod);

assert_eq(prod(2, 3), prod_curried(2)(3));

var dot = function(_a, _b, _c, _d) {
	return dot_product(_a, _b, _c, _d);
}

var dot_curried = curry_quad(dot)(2)(3);

assert_eq(dot(2, 3, 8, 12), dot_curried(8)(12));
assert_eq(dot(2, 3, 7, 12), dot_curried(7)(12));