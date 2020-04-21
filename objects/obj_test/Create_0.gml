gml_pragma("global", @'room_instance_add(room_first, 0, 0, obj_test);');
/// @desc Perform tests.

show_debug_message("-------# tests begin #-------\n");

var a = array_mapf([1,2,3,4], function(_x) {
	show_debug_message(_x);
	return _x * _x;
});
show_debug_message(a);

var num_iter = new Iterator(function() {
	static count = 0;
	count += 1;
	if (count > 100)
	then throw new StopIteration();
	else return count;
});

var arr_wrapper = {
	arr : [1, 2, 3],
	next : function() {
		static i = 0;
		var pos = i;
		i += 1;
		if (pos < array_length(arr))
		then return arr[pos];
		else throw new StopIteration();
	}
};

var arr_iter = new Iterator(arr_wrapper.next);

function add(_a) {
	var closure = {
		a : _a,
		f : function(_b) {
			return a + _b;
		}
	};
	return closure.f;
}

/* Doesn't work
function false_add(_a) {
	return function(_b) {
		return _a + _b;
	}
}
*/

var result = add(1)(2);
// var false_result = false_add(1)(2);
show_debug_message("closure test: " + string(result));

array_foreach(iterate(arr_iter), function(_x) {
	show_debug_message("value: " + string(_x));
})

show_debug_message("\n-------#  tests end  #-------");