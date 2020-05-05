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
	static seen = [];
	assert_true(array_contains(["a", "b", "c"], _key));
	assert_false(array_contains(seen, _key));
	seen[array_length(seen)] = _key;
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
struct_foreach_key(struct, function(_key) {
	static seen = [];
	assert_true(array_contains(["a", "b", "c"], _key));
	assert_false(array_contains(seen, _key));
	seen[array_length(seen)] = _key;
});
struct_foreach_value(struct, function(_value) {
	static seen = [];
	assert_true(array_contains(["A", "B", "C"], _value));
	assert_false(array_contains(seen, _value));
	seen[array_length(seen)] = _value;
});