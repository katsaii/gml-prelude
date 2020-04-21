/* Functional Programming Library by Kat @Katsaii
 * `https://github.com/NuxiiGit/functionalism`
 */

#region array

/// @desc Applies a function to all elements of an array and returns a new array.
/// @param {array} variable The array to apply the function to.
/// @param {script} f The function to apply to all elements in the array.
/// @param {int} [n] The size of the output array.
/// @param {int} [i=0] The index of the array to start at.
function array_mapf(_array, _f) {
	var n = argument_count > 2 ? argument[2] : array_length(_array);
	var i = argument_count > 3 ? argument[3] : 0;
	var clone = array_create(n);
	for (var j = 0; j < n; j += 1) {
		clone[@ j] = _f(_array[j + i]);
	}
	return clone;
}

/// @desc Calls some procedure for each element of an array.
/// @param {array} variable The array to apply the function to.
/// @param {script} f The function to apply to all elements in the array.
/// @param {int} [n] The number of elements to loop through.
/// @param {int} [i=0] The index of the array to start at.
function array_foreach(_array, _f) {
	var n = argument_count > 2 ? argument[2] : array_length(_array);
	var i = argument_count > 3 ? argument[3] : 0;
	for (; i < n; i += 1) {
		_f(_array[i]);
	}
}

#endregion

#region iterator

/// @desc Creates a new iterator instance with this function.
/// @param {script} generator The function which will generate values for the iterator.
function Iterator(_generator) constructor {
	generator = _generator;
	peeked = undefined;
	next = function() {
		var item = peeked;
		if (item == undefined)
		then item = generator();
		else peeked = undefined;
		return item;
	};
	peek = function() {
		if (peeked == undefined)
		then peeked = generator();
		return peeked;
	}
}

/// @desc Converts an iterator into an array.
/// @param {Iterator} iter The iterator to generate values from.
function iterate(_iter) {
	var queue = ds_queue_create();
	var n = 0;
	while (_iter.peek() != undefined) {
		ds_queue_enqueue(queue, _iter.next());
		n += 1;
	}
	var arr = array_create(n);
	for (var i = 0; i < n; i += 1) {
		arr[@ i] = ds_queue_dequeue(queue);
	}
	ds_queue_destroy(queue);
	return arr;
}

#endregion