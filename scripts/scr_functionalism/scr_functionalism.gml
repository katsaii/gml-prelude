/* Functional Programming Library by Kat @Katsaii
 * `https://github.com/NuxiiGit/functionalism`
 */

/// @desc Applies a function to all elements of an array and returns a new array.
/// @param {array} variable The array to apply the function to.
/// @param {script} f The function to apply to all elements in the array.
/// @param {int} [n] The size of the output array.
/// @param {int} [i] The index of the array to start at.
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
/// @param {int} [i] The index of the array to start at.
function array_foreach(_array, _f) {
	var n = argument_count > 2 ? argument[2] : array_length(_array);
	var i = argument_count > 3 ? argument[3] : 0;
	for (; i < n; i += 1) {
		_f(_array[i]);
	}
}


