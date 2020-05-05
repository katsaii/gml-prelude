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
var result = array_map(array, function(_x) { return _x + "izard" }, 2, 1);
assert_eq(["Bizard", "Cizard"], result);

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

// tests folding
array = ["alpha", "beta", "gamma"];
var y0 = "fishward";
var f = function(_xs, _x) {
	return _xs + "-" + _x;
}
assert_eq("fishward-alpha-beta-gamma", array_foldl(array, y0, f));
assert_eq("alpha-beta-gamma-fishward", array_foldr(array, y0, f));
assert_eq("fishward-beta-gamma", array_foldl(array, y0, f, 2, 1));
assert_eq("alpha-beta-fishward", array_foldr(array, y0, f, 2));