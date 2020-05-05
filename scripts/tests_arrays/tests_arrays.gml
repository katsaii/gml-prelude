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

// tests map
array = ["A", "B", "C", "D"];
assert_eq([65, 66, 67, 68], array_map(array, func_ptr(ord)));
assert_eq(["Bizard", "Cizard"], array_map(array, function(_x) { return _x + "izard" }, 2, 1));

// tests foreach
array = [1, 2, 3];
array_foreach(array, function(_x) {
	static i = 0;
	i += 1;
	switch (i) {
	case 1:
		assert_eq(1, _x);
		break;
	case 2:
		assert_eq(2, _x);
		break;
	case 3:
		assert_eq(3, _x);
		break;
	}
});