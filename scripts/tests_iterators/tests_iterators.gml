/* Tests iterator behaviour
 * Kat @Katsaii
 */

var iter;
var ds;
var array;

// tests array iterators
iter = new Iterator([1, 2, 3]);
assert_eq(1, iter.Next());
assert_eq(2, iter.Next());
assert_eq([3], iter.Collect());
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
iter = iter.Filter(function(_x) { return _x < 3 });
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

// tests list iterator
ds = ds_list_create();
ds_list_add(ds, "A", "Z", 12);
iter = new Iterator(ds, ds_type_list);
assert_eq(["A", "Z", 12], iter.Collect());
ds_list_destroy(ds);

// tests grid iterator
ds = ds_grid_create(2, 2);
ds[# 0, 0] = 1;
ds[# 1, 0] = 2;
ds[# 0, 1] = 3;
ds[# 1, 1] = 4;
iter = new Iterator(new GridReader(ds, true));
assert_eq([1, 2, 3, 4], iter.Collect());
iter = new Iterator(new GridReader(ds, false));
assert_eq([1, 3, 2, 4], iter.Collect());
ds_grid_destroy(ds);

// tests map iterator
ds = ds_map_create();
ds[? "A"] = -1;
ds[? "B"] = -2;
ds[? "C"] = -3;
iter = new Iterator(ds, ds_type_map);
assert_eq(true, array_is_permutation([["A", -1], ["B", -2], ["C", -3]], iter.Collect()));
ds_map_destroy(ds);

// tests First and TakeWhile
iter = range(1, 15);
assert_eq(4, iter.First(function(_x) { return _x > 3 }));
assert_eq([5, 6, 7, 8, 9], iter.TakeWhile(function(_x) { return _x < 10 }));
assert_eq([10, 11, 12, 13, 14], iter.TakeUntil(function(_x) { return _x == 15 }));

// tests All
iter = range(0, 100, 2);
assert_eq(true, iter.All(function(_x) { return _x % 2 == 0 }));

// tests Any
iter = range(0, infinity);
assert_eq(true, iter.Any(function(_x) { return _x == 150 }));

// tests string concatenation
iter = new Iterator(["hello", " ", "world"]);
iter = iter.Concat();
assert_eq("hello world", iter.Sum(ty_string));

// tests Seek and Reset
iter = new Iterator(["I", "J", "K", "L"]);
assert_eq("I", iter.Next());
iter.Seek(2);
assert_eq("K", iter.Next());
assert_eq("L", iter.Next());
iter.Reset();
assert_eq("I", iter.Next());
assert_eq("J", iter.Peek());
iter.Seek(iter.Location() + 2);
assert_eq("L", iter.Next());

// tests Append
iter = new Iterator("hello");
iter = iter.Append(new Iterator("world"));
assert_eq("helloworld", iter.Fold("", function(_xs, _x) { return _xs + _x }));

// tests Sum and Product
iter = new Iterator("123920");
assert_eq(17, iter.Sum(ty_real));
iter.Reset();
assert_eq(0, iter.Product(ty_real));