/* Tests monads
 * Kat @Katsaii
 */

var f;

// test bind
f = function(_x) { return 2 * _x };
assert_eq(2, bind(1, f));
assert_eq(undefined, bind(undefined, f));
assert_eq(undefined, bind(12, undefined));