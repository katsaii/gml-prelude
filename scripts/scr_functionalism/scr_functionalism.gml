/* Functional Programming Library by Kat @Katsaii
 * `https://github.com/NuxiiGit/functionalism`
 */

/// @desc Applies a function to all elements of an array and returns a new array.
/// @param {array} variable The array to apply the function to.
/// @param {script} f The function to apply to all elements in the array.
function array_mapf(_array, _f) {
	var n = array_length(_array);
	var clone = array_create(n);
	array_copy(clone, 0, _array, 0, n);
	for (var i = 0; i < n; i += 1) {
		clone[@ i] = _f(clone[i]);
	}
	return clone;
}

/// @desc Calls some procedure for each element of an array.
/// @param {array} variable The array to apply the function to.
/// @param {script} f The function to apply to all elements in the array.
function array_foreach(_array, _f) {
	var n = array_length(_array);
	for (var i = 0; i < n; i += 1) {
		_f(_array[i]);
	}
}