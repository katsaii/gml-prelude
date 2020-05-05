/* Tests array extensions
 * Kat @Katsaii
 */

var array;

// tests cloning
array = [1, 2, 3];
assert_neq(array, array_clone(array));

// tests empty
assert_true(array_empty([]));
assert_false(array_empty(["A"]));
assert_false(array_empty([[]]));

// tests find index
array = [1, 2, "X", 4, 5, 6];
assert_eq(2, array_find_index(array, "X"));
assert_eq(-1, array_find_index(array, "X", 2));
assert_eq(-1, array_find_index(array, "X", 2, 3));
