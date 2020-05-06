/* Tests iterator behaviour
 * Kat @Katsaii
 */

var iter;
var ds;
var array;

// tests array iterators
iter = new Iterator([1, 2, 3]);
assert_eq(1, iter.next());
assert_eq(2, iter.next());
assert_eq([3], iter.collect());
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
iter = iter.filter(function(_x) { return _x < 3 });
assert_eq([1, 2, -1, -1, -2], iter.collect());

// tests folding and other combinations of operations
iter = new Iterator(["A", "B", "C"]);
iter = iter.map(function(_x) { return [ord(_x), _x]; });
ds = iter.collect(ds_type_stack);
assert_eq([67, "C"], ds_stack_pop(ds));
assert_eq([66, "B"], ds_stack_pop(ds));
assert_eq([65, "A"], ds_stack_pop(ds));
ds_stack_destroy(ds);

// tests forEach
iter = new Iterator(["A", "B", "C"]);
iter.forEach(function(_x) {
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
assert_eq(["A", "Z", 12], iter.collect());
ds_list_destroy(ds);

// tests grid iterator
ds = ds_grid_create(2, 2);
ds[# 0, 0] = 1;
ds[# 1, 0] = 2;
ds[# 0, 1] = 3;
ds[# 1, 1] = 4;
iter = new Iterator(new GridReader(ds, true));
assert_eq([1, 2, 3, 4], iter.collect());
iter = new Iterator(new GridReader(ds, false));
assert_eq([1, 3, 2, 4], iter.collect());
ds_grid_destroy(ds);

// tests map iterator
ds = ds_map_create();
ds[? "A"] = -1;
ds[? "B"] = -2;
ds[? "C"] = -3;
iter = new Iterator(ds, ds_type_map);
assert_eq(true, array_is_permutation([["A", -1], ["B", -2], ["C", -3]], iter.collect()));
ds_map_destroy(ds);

// tests first and takeWhile
iter = range(1, 15);
assert_eq(4, iter.first(function(_x) { return _x > 3 }));
assert_eq([5, 6, 7, 8, 9], iter.takeWhile(function(_x) { return _x < 10 }));
assert_eq([10, 11, 12, 13, 14], iter.takeUntil(function(_x) { return _x == 15 }));

// tests each
iter = range(0, 100, 2);
assert_eq(true, iter.each(function(_x) { return _x % 2 == 0 }));

// tests some
iter = range(0, infinity);
assert_eq(true, iter.some(function(_x) { return _x == 150 }));

// tests string concatenation
iter = new Iterator(["hello", " ", "world"]);
assert_eq("hello world", iter.sum(ty_string));

// tests seek and reset
iter = new Iterator(["I", "J", "K", "L"]);
assert_eq("I", iter.next());
iter.seek(2);
assert_eq("K", iter.next());
assert_eq("L", iter.next());
iter.reset();
assert_eq("I", iter.next());
assert_eq("J", iter.peek());
iter.seek(iter.location() + 2);
assert_eq("L", iter.next());

// tests nudge
iter = new Iterator("hiya");
iter.nudge(3);
assert_eq("a", iter.peek());
iter.nudge(-2);
assert_eq("i", iter.next());

// tests append
iter = new Iterator("hello");
iter = iter.append(new Iterator("world"));
assert_eq("helloworld", iter.fold("", function(_xs, _x) { return _xs + _x }));

// tests sum and product
iter = new Iterator("123920");
assert_eq(17, iter.sum(ty_real));
iter.reset();
assert_eq(0, iter.product(ty_real));

// tests word reader
iter = new Iterator(new WordReader(",a,b,cd,e,f1,,", ","));
assert_eq(["", "a", "b", "cd", "e", "f1", "", ""], iter.collect());
assert_eq(undefined, iter.next());
iter = new Iterator(new WordReader("", ","));
assert_eq("", iter.next());
assert_eq(undefined, iter.next());
iter = new Iterator(new WordReader("wizardfizardblizardgizard", "izard"));
assert_eq(["w", "f", "bl", "g", ""], iter.collect());
assert_eq(undefined, iter.next());

// tests nested readers
iter = new Iterator(new WordReader("a:1,b:2,c:3", ","));
iter = iter.map(function(_x) { return new Iterator(new WordReader(_x, ":")).collect() });
assert_eq([["a", "1"], ["b", "2"], ["c", "3"]], iter.collect());

// tests iterate
iter = iterate(0, function(_x) { return _x + 1 });
iter.drop(10);
assert_eq([10, 11, 12, 13, 14], iter.take(5));

// tests file reader
ds = file_text_open_from_string("line1\nline2\nline3");
iter = new Iterator(new FileReader(ds));
assert_eq(["line1", "line2", "line3"], iter.collect());
file_text_close(ds);