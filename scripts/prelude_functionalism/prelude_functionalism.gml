/* Functional Programming Library by Kat @Katsaii
 * `https://github.com/NuxiiGit/functionalism`
 * Kat @Katsaii
 */

#region iterator

/// @desc Creates a new iterator instance with this function.
/// @param {script} generator The function which will generate values for the iterator.
function Iterator(_generator) constructor {
	generator = _generator;
	has_peeked = false;
	peeked = undefined;
}

/// @desc Advance the iterator and return its next value.
/// @param {Iterator} iter The iterator to advance.
function next(_iter) {
	var item;
	if (_iter.has_peeked) {
		_iter.has_peeked = false;
		item = _iter.peeked;
	} else {
		item = _iter.generator.next();
	}
	return item;
}

/// @desc Peek at the next iterator value.
/// @param {Iterator} iter The iterator to peek at the next value of.
function peek(_iter) {
	if not (_iter.has_peeked) {
		_iter.peeked = _iter.generator.next();
		_iter.has_peeked = true;
	}
	return _iter.peeked;
}

/// @desc An exception which tells the iterator to stop running.
function StopIteration() constructor { }

/// @desc Converts an iterator into an array.
/// @param {Iterator} iter The iterator to generate values from.
function iterate(_iter) {
	var array = [];
	try {
		for (var i = 0; true; i += 1) {
			array[@ i] = next(_iter);
		}
	} catch (_exception) {
		if (instanceof(_exception) != script_get_name(StopIteration))
		then throw _exception;
	}
	return array;
}

#endregion

#region struct

/// @desc Clones a struct.
/// @param {struct} struct The struct to clone.
function struct_clone(_struct) {
	var clone = { };
	var n = variable_struct_names_count(_struct);
	var names = variable_struct_get_names(_struct);
	for (var i = n - 1; i >= 0; i -= 1) {
		var variable = names[i];
		variable_struct_set(
				clone, variable,
				variable_struct_get(_struct, variable));
	}
	return clone;
}

/// @desc Calls some procedure for each member of a struct.
/// @param {struct} struct The struct to apply the function to.
/// @param {script} f The function to apply to all member of the struct.
function struct_foreach(_struct, _f) {
	var n = variable_struct_names_count(_struct);
	var names = variable_struct_get_names(_struct);
	for (var i = n - 1; i >= 0; i -= 1) {
		var variable = names[i];
		_f(variable_struct_get(_struct, variable));
	}
}

/// @desc Returns an iterator over all members of the struct.
/// @param {array} variable The array to convert into an iterator.
function struct_into_iterator(_struct) {
	return new Iterator({
		struct : _struct,
		names : variable_struct_get_names(_struct),
		pos : 0,
		len : variable_struct_names_count(_struct),
		next : function() {
			if (pos < len) {
				var variable = names[pos];
				var data = {
					name : variable,
					value : variable_struct_get(struct, variable)
				};
				pos += 1;
				return data;
			} else {
				throw new StopIteration();
			}
		}
	});
}

#endregion