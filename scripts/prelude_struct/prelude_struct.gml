/* Struct operations
 * Kat @Katsaii
 */

/// @desc Clones a struct.
/// @param {struct} struct The struct to clone.
function struct_clone(_struct) {
	var clone = { };
	var count = variable_struct_names_count(_struct);
	var names = variable_struct_get_names(_struct);
	for (var i = count - 1; i >= 0; i -= 1) {
		var key = names[i];
		var val = variable_struct_get(_struct, key);
		variable_struct_set(clone, key, val);
	}
	return clone;
}

/// @desc Calls some procedure for each key-value pairs of a struct.
/// @param {struct} struct The struct to apply the function to.
/// @param {script} f The function to apply.
function struct_foreach(_struct, _f) {
	var count = variable_struct_names_count(_struct);
	var names = variable_struct_get_names(_struct);
	for (var i = count - 1; i >= 0; i -= 1) {
		var key = names[i];
		var val = variable_struct_get(_struct, key);
		_f(key, val);
	}
}

/// @desc Calls some procedure for each member name of a struct.
/// @param {struct} struct The struct to apply the function to.
/// @param {script} f The function to apply.
function struct_foreach_key(_struct, _f) {
	struct_foreach(_struct, function(_key, _) { _f(_key); });
}

/// @desc Calls some procedure for each member value of a struct.
/// @param {struct} struct The struct to apply the function to.
/// @param {script} f The function to apply.
function struct_foreach_value(_struct, _f) {
	struct_foreach(_struct, function(_, _value) { _f(_value); });
}