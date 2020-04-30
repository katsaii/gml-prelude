/* Tests iterator behaviour
 * Kat @Katsaii
 */

var iter;
var ds;
var array;

// tests array iterators
iter = new Iterator([1, 2, 3]);
assert_eq(1, iter.next());
assert_eq([2, 3], iter.collect());
assert_eq([undefined, undefined, undefined], iter.take(3));

// tests struct iterators
iter = new Iterator({
	pos : 0,
	__next__ : function() {
		pos += 1;
		return pos;
	}
});
assert_eq([1, 2, 3, 4], iter.take(4));
iter.drop(4); // [5, 6, 7, 8]
assert_eq([9], iter.take(1));
assert_eq([], iter.take(0));

// tests enumeration
iter = new Iterator(["A", "B", "C", "D", "D", "F", "K"]);
iter = iter.enumerate();
assert_eq([0, "A"], iter.peek());
assert_eq([0, "A"], iter.next());
assert_eq([[1, "B"], [2, "C"], [3, "D"], [4, "D"]], iter.take(4));
assert_eq([[5, "F"], [6, "K"]], iter.collect());
assert_eq(undefined, iter.next());

// tests concatenation
iter = new Iterator(["X", "Y", "Z"]);
iter = iter.enumerate();
iter = iter.concat();
assert_eq([0, "X", 1, "Y", 2, "Z"], iter.collect());

// tests mapping
iter = new Iterator([0, 1, 2, 3, 4]);
iter = iter.map(function(_x) { return _x * _x; });
assert_eq([0, 1, 4, 9, 16], iter.collect());

// tests folding/collections
array = ["A", "B", "C"];
iter = new Iterator(array);
ds = iter.collect(ds_type_list);
for (var i = 0; i < array_length(array); i += 1) {
	assert_eq(array[i], ds[| i]);
}
ds_list_destroy(ds);

// tests filtering
iter = new Iterator([1, 2, 3, 4, 5, -1, -1, -2]);
iter = iter.filter(op_less(3));
assert_eq([1, 2, -1, -1, -2], iter.collect());

// tests folding and other combinations of operations
iter = new Iterator(["A", "B", "C"]);
iter = iter.map(function(_x) { return [ord(_x), _x]; });
iter = iter.concat();
ds = iter.collect(ds_type_stack);
assert_eq("C", ds_stack_pop(ds));
assert_eq(67, ds_stack_pop(ds));
assert_eq("B", ds_stack_pop(ds));
assert_eq(66, ds_stack_pop(ds));
assert_eq("A", ds_stack_pop(ds));
assert_eq(65, ds_stack_pop(ds));
ds_stack_destroy(ds);

// tests foreach
iter = new Iterator(["A", "B", "C"]);
iter.foreach(function(_x) {
	static i = 0;
	switch (i) {
	case 0:
		assert_eq("A", _x);
		break;
	case 1:
		assert_eq("B", _x);
		break;
	case 2:
		assert_eq("C", _x);
		break;
	}
	i += 1;
});