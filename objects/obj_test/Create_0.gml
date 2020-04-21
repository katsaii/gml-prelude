gml_pragma("global", @'room_instance_add(room_first, 0, 0, obj_test);');
/// @desc Perform tests.

show_debug_message("-------# tests begin #-------\n");

var a = array_mapf([1,2,3,4], function(_x) {
	show_debug_message(_x);
	return _x * _x;
});
show_debug_message(a);

var iter = new Iterator(function () {
	static count = 0;
	count += 1;
	if (count > 100)
	then return undefined;
	else return count;
});

array_foreach(iterate(iter), function(_x) {
	show_debug_message("value: " + string(_x));
})

show_debug_message("\n-------#  tests end  #-------");