/* Tests array operations
 * Kat @Katsaii
 */

var arr = ["a", "b", "d", "f", "k", "r", "z"];

var arr_enum = array_enumerate(arr);

assert_eq([[0, "a"], [1, "b"], [2, "d"], [3, "f"], [4, "k"], [5, "r"], [6, "z"]], arr_enum);

assert_eq([0, "a", 1, "b", 2, "d", 3, "f", 4, "k", 5, "r", 6, "z"], array_flatten(arr_enum));