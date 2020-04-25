/* Tests iterator behaviour
 * Kat @Katsaii
 */

var iter = iterator([1, 2, 3]);

assert_eq(1, next(iter));

assert_eq([2, 3], iterate(iter));