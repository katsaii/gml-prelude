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
assert_eq(undefined, iter.next());

// tests struct iterators
iter = new Iterator({
	pos : 0,
	__next__ : function() {
		pos += 1;
		return pos;
	}
});
iter.drop(4);
iter.take(4);
assert_eq([5, 6, 7, 8], iter.collect());

// tests enumeration
iter = new Iterator(["A", "B", "C", "D", "D", "F", "K"]);
iter = iter.enumerate();
assert_eq(["A", 0], iter.peek());
assert_eq(["A", 0], iter.next());
iter.take(4);
assert_eq([["B", 1], ["C", 2], ["D", 3], ["D", 4]], iter.collect());

// tests mapping
iter = new Iterator([0, 1, 2, 3, 4]);
iter.map(function(_x) { return _x * _x; });
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
iter.filter(function(_x) { return _x < 3 });
assert_eq([1, 2, -1, -1, -2], iter.collect());

// tests folding and other combinations of operations
iter = new Iterator(["A", "B", "C"]);
iter.map(function(_x) { return [ord(_x), _x]; });
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
assert_eq(@'[ "1", "2", "3" ]', iter.toString());

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
assert_eq([5, 6, 7, 8, 9], (iter.takeWhile(function(_x) { return _x < 10 })).collect());

// tests each
iter = range(0, 100, 2);
assert_eq(true, iter.each(function(_x) { return _x % 2 == 0 }));

// tests some
iter = range(0, infinity);
assert_eq(true, iter.some(function(_x) { return _x == 150 }));

// tests string concatenation
iter = new Iterator(["hello", " ", "world"]);
assert_eq("hello world", iter.sum(ty_string));

// tests append
iter = new Iterator("hello");
iter = iter.extend(new Iterator("world"));
assert_eq("helloworld", iter.fold("", function(_xs, _x) { return _xs + _x }));

// tests sum
iter = new Iterator("123920");
assert_eq(17, iter.sum(ty_real));

// tests product
iter = new Iterator("924");
assert_eq(72, iter.product(ty_real));

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
iter = iter.drop(10);
assert_eq(10, iter.next());
assert_eq(11, iter.next());
assert_eq(12, iter.next());
assert_eq(13, iter.next());

// tests file reader
ds = file_text_open_from_string("line1\nline2\nline3");
iter = new Iterator(new FileReader(ds));
assert_eq(["line1", "line2", "line3"], iter.collect());
file_text_close(ds);

// tests nth
iter = new Iterator("abcde");
assert_eq("c", iter.nth(2));
assert_eq("e", iter.nth(1));
assert_eq(undefined, iter.nth(0));
assert_eq(undefined, iter.nth(12));

// tests takeUntil
iter = range(0, 100);
iter.drop(10);
iter.takeUntil(function(_x) { return _x == 15 });
assert_eq([10, 11, 12, 13, 14], iter.collect());