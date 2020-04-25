/* Tests currying of functions
 * Kat @Katsaii
 */

var f = func_ptr(array_create);

assert_eq([0, 0, 0], f(3));