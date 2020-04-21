gml_pragma("global", @'room_instance_add(room_first, 0, 0, obj_test);');
/// @desc Perform tests.

var a = array_mapf([1,2,3,4], function(_x) {
	show_message(_x);
	return _x * _x;
});
show_message(a);