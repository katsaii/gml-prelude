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

/// @desc Calls some procedure for each key-value member of a struct.
/// @param {struct} struct The struct to apply the function to.
/// @param {script} f The function to apply to all member of the struct.
function struct_foreach(_struct, _f) {
	var count = variable_struct_names_count(_struct);
	var names = variable_struct_get_names(_struct);
	for (var i = count - 1; i >= 0; i -= 1) {
		var key = names[i];
		var val = variable_struct_get(_struct, key);
		_f(key, val);
	}
}
