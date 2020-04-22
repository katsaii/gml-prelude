gml_pragma("global", @'room_instance_add(room_first, 0, 0, obj_test);');
/// @desc Perform tests.

show_debug_message("-------# tests begin #-------\n");

var a = array_mapf([1,2,3,4], function(_x) {
	show_debug_message(_x);
	return _x * _x;
});
show_debug_message(a);

var num_iter = new Iterator({ next : function() {
	static count = 0;
	count += 1;
	if (count > 100)
	then throw new StopIteration();
	else return count;
}});

var arr_iter = array_into_iterator([1, 2, 3]);

array_foreach(iterate(arr_iter), function(_x) {
	show_debug_message("value: " + string(_x));
})

var mult = function(_a, _b) {
	return _a * _b;
}

var mult_curried = curry_pair(mult);

show_debug_message("uncurried:");
show_debug_message(mult(2, 3));
show_debug_message("curried:");
show_debug_message(mult_curried(2)(3));

var dot = function(_a, _b, _c, _d) {
	return dot_product(_a, _b, _c, _d);
}

var dot_curried = curry_quad(dot);

show_debug_message("uncurried:");
show_debug_message(dot(2, 3, 8, 12));
show_debug_message("curried:");
show_debug_message(dot_curried(2)(3)(8)(12));

show_debug_message("\n-------#  tests end  #-------");