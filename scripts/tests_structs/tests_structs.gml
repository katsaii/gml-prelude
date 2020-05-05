/* Tests struct extensions
 * Kat @Katsaii
 */

var struct;

// tests cloning
struct = { x : 1, y : 3 };
assert_neq(struct, struct_clone(struct));

// tests foreach
struct = { a : "A", b : "B", c : "C" };
struct_foreach(struct, function(_key, _value) {
	assert_true(array_contains(_key, ["a", "b", "c"]));
	switch (_key) {
	case "a":
		assert_eq("A", _value);
		break;
	case "b":
		assert_eq("B", _value);
		break;
	case "c":
		assert_eq("C", _value);
		break;
	}
});