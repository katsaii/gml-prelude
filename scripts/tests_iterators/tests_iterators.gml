/* Tests iterator behaviour
 * Kat @Katsaii
 */

var iter;
var ds;
var array;

// tests array iterators
iter = new Iterator([1, 2, 3]);
assert_eq(1, iter.Next());
assert_eq([2, 3], iter.Collect());
assert_eq([undefined, undefined, undefined], iter.Take(3));

// tests struct iterators
iter = new Iterator({
	pos : 0,
	__next__ : function() {
		pos += 1;
		return pos;
	}
});
assert_eq([1, 2, 3, 4], iter.Take(4));
iter.Drop(4); // [5, 6, 7, 8]
assert_eq([9], iter.Take(1));
assert_eq([], iter.Take(0));

// tests enumeration
iter = new Iterator(["A", "B", "C", "D", "D", "F", "K"]);
iter = iter.Enumerate();
assert_eq([0, "A"], iter.Peek());
assert_eq([0, "A"], iter.Next());
assert_eq([[1, "B"], [2, "C"], [3, "D"], [4, "D"]], iter.Take(4));
assert_eq([[5, "F"], [6, "K"]], iter.Collect());
assert_eq(undefined, iter.Next());

// tests concatenation
iter = new Iterator(["X", "Y", "Z"]);
iter = iter.Enumerate();
iter = iter.Concat();
assert_eq([0, "X", 1, "Y", 2, "Z"], iter.Collect());

// tests mapping
iter = new Iterator([0, 1, 2, 3, 4]);
iter = iter.Map(function(_x) { return _x * _x; });
assert_eq([0, 1, 4, 9, 16], iter.Collect());

// tests folding/collections
array = ["A", "B", "C"];
iter = new Iterator(array);
ds = iter.Collect(ds_type_list);
for (var i = 0; i < array_length(array); i += 1) {
	assert_eq(array[i], ds[| i]);
}
ds_list_destroy(ds);

// tests filtering
iter = new Iterator([1, 2, 3, 4, 5, -1, -1, -2]);
iter = iter.Filter(op_less(3));
assert_eq([1, 2, -1, -1, -2], iter.Collect());

// tests folding and other combinations of operations
iter = new Iterator(["A", "B", "C"]);
iter = iter.Map(function(_x) { return [ord(_x), _x]; });
iter = iter.Concat();
ds = iter.Collect(ds_type_stack);
assert_eq("C", ds_stack_pop(ds));
assert_eq(67, ds_stack_pop(ds));
assert_eq("B", ds_stack_pop(ds));
assert_eq(66, ds_stack_pop(ds));
assert_eq("A", ds_stack_pop(ds));
assert_eq(65, ds_stack_pop(ds));
ds_stack_destroy(ds);

// tests ForEach
iter = new Iterator(["A", "B", "C"]);
iter.ForEach(function(_x) {
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

// tests toString
iter = new Iterator("123");
assert_eq(@'["1", "2", "3"]', iter.toString());