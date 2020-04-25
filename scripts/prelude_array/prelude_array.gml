/* Array operations (See: `https://github.com/NuxiiGit/gml-prelude`)
 * Kat @Katsaii
 */

/// @desc Clones an array.
/// @param {array} variable The array to clone.
function array_clone(_array) {
	if (array_length(_array) < 1) {
		return [];
	} else {
		_array[0] = _array[0];
		return _array;
	}
}

/// @desc Applies a function to all elements of an array and returns a new array.
/// @param {script} f The function to apply to all elements in the array.
/// @param {array} variable The array to apply the function to.
/// @param {int} [n] The size of the output array.
/// @param {int} [i=0] The index of the array to start at.
function array_mapf(_f, _array) {
	var count = argument_count > 2 ? argument[2] : array_length(_array);
	var start = argument_count > 3 ? argument[3] : 0;
	var clone = array_create(count);
	for (var i = 0; i < count; i += 1) {
		clone[@ i] = _f(_array[start + i]);
	}
	return clone;
}

/// @desc Calls some procedure for each element of an array.
/// @param {script} f The function to apply to all elements in the array.
/// @param {array} variable The array to apply the function to.
/// @param {int} [n] The number of elements to loop through.
/// @param {int} [i=0] The index of the array to start at.
function array_foreach(_f, _array) {
	var count = argument_count > 2 ? argument[2] : array_length(_array);
	var start = argument_count > 3 ? argument[3] : 0;
	for (var i = 0; i < count; i += 1) {
		_f(_array[start + i]);
	}
}

/// @desc Enumerates elements in an array.
/// @param {array} variable The array to enumerate.
function array_enumerate(_array) {
	var count = array_length(_array);
	var array = array_create(count);
	for (var i = count - 1; i >= 0; i -= 1) {
		array[@ i] = [i, _array[i]];
	}
	return array;
}