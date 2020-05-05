/* Data structure operations (See: `https://github.com/NuxiiGit/gml-prelude`)
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
function array_map(_f, _array) {
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

/// @desc Returns whether two arrays are permutations of each other. Assumes non-duplicate elements.
/// @param {array} a The subset to check.
/// @param {array} b The superset to check.
function array_is_permutation(_a, _b) {
	return array_is_subset(_a, _b) && array_is_subset(_b, _a);
}

/// @desc Checks whether one array is a subset of another. Assumes non-duplicate elements.
/// @param {array} a The subset to check.
/// @param {array} b The superset to check.
function array_is_subset(_a, _b) {
	var count = array_length(_a);
	for (var i = count - 1; i >= 0; i -= 1) {
		if not (array_contains(_b, _a[i])) {
			return false;
		}
	}
	return true;
}

/// @desc Checks whether an array contains a value.
/// @param {array} variable The array to consider.
/// @param {value} value The value to compare.
function array_contains(_array, _target) {
	var count = array_length(_array);
	var compare_arrays = is_array(_target);
	for (var i = count - 1; i >= 0; i -= 1) {
		var val = _array[i];
		if (compare_arrays && is_array(val) &&
				array_equals(val, _target) ||
				val == _target) {
			return true;
		} 
	}
	return false;
}

/// @desc Applies a left-associative operation to all elements of this array in sequence.
/// @param {array} variable The array to consider.
/// @param {value} y0 The default value.
/// @param {script} f The function to apply.
function array_foldl(_array, _y0, _f) {
	var count = array_length(_array);
	var acc = _y0;
	for (var i = 0; i < count; i += 1) {
		acc = _f(acc, _array[i]);
	}
	return acc;
}

/// @desc Applies a right-associative operation to all elements of this array in sequence.
/// @param {array} variable The array to consider.
/// @param {value} y0 The default value.
/// @param {script} f The function to apply.
function array_foldr(_array, _y0, _f) {
	var count = array_length(_array);
	var acc = _y0;
	for (var i = count - 1; i >= 0; i -= 1) {
		acc = _f(_array[i], acc);
	}
	return acc;
}

/// @desc Clones a struct.
/// @param {struct} struct The struct to clone.
function struct_clone(_struct) {
	if (instanceof(_struct) != "struct") {
		throw "structs created using constructor functions are not supported";
	}
	var clone = { };
	var count = variable_struct_names_count(_struct);
	var names = variable_struct_get_names(_struct);
	for (var i = count - 1; i >= 0; i -= 1) {
		var key = names[i];
		var val = variable_struct_get(_struct, key);
		if (is_method(val) && method_get_self(val) == _struct) {
			throw "cannot clone structs which contain methods bound to self";
		}
		variable_struct_set(clone, key, val);
	}
	return clone;
}

/// @desc Calls some procedure for each key-value pairs of a struct.
/// @param {script} f The function to apply.
/// @param {struct} struct The struct to apply the function to.
function struct_foreach(_f, _struct) {
	var count = variable_struct_names_count(_struct);
	var names = variable_struct_get_names(_struct);
	for (var i = count - 1; i >= 0; i -= 1) {
		var key = names[i];
		var val = variable_struct_get(_struct, key);
		_f(key, val);
	}
}

/// @desc Calls some procedure for each member name of a struct.
/// @param {script} f The function to apply.
/// @param {struct} struct The struct to apply the function to.
function struct_foreach_key(_f, _struct) {
	struct_foreach(_struct, function(_key, _) { _f(_key); });
}

/// @desc Calls some procedure for each member value of a struct.
/// @param {script} f The function to apply.
/// @param {struct} struct The struct to apply the function to.
function struct_foreach_value(_f, _struct) {
	struct_foreach(_struct, function(_, _value) { _f(_value); });
}