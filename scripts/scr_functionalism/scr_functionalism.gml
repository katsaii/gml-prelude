/* Functional Programming Library by Kat @Katsaii
 * `https://github.com/NuxiiGit/functionalism`
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
		if (instanceof(_exception) != "StopIteration")
		then throw _exception;
	}
	return array;
}

#endregion

#region array

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

/// @desc Returns an iterator over all elements of an array.
/// @param {array} variable The array to convert into an iterator.
function array_into_iterator(_array) {
	return new Iterator({
		array : _array,
		pos : 0,
		len : array_length(_array),
		next : function() {
			if (pos < len) {
				var val = array[pos];
				pos += 1;
				return val;
			} else {
				throw new StopIteration();
			}
		}
	});
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

#region currying

/// @desc Curries a function which takes two arguments.
/// @param {script} ind The id of the script to apply currying to.
function curry_pair(_f) {
	return method({
		f : _f
	}, function(_a) {
		return method({
			f : self.f,
			a : _a
		}, function(_b) {
			return f(a, _b);
		});
	});
}

/// @desc Curries a function which takes three arguments.
/// @param {script} ind The id of the script to apply currying to.
function curry_trip(_f) {
	return method({
		f : _f
	}, function(_a) {
		return method({
			f : self.f,
			a : _a
		}, function(_b) {
			return method({
				f : self.f,
				a : self.a,
				b : _b
			}, function(_c) {
				return f(a, b, _c);
			});
		});
	});
}

/// @desc Curries a function which takes four arguments.
/// @param {script} ind The id of the script to apply currying to.
function curry_quad(_f) {
	return method({
		f : _f
	}, function(_a) {
		return method({
			f : self.f,
			a : _a
		}, function(_b) {
			return method({
				f : self.f,
				a : self.a,
				b : _b
			}, function(_c) {
				return method({
					f : self.f,
					a : self.a,
					b : self.b,
					c : _c
				}, function(_d) {
					return f(a, b, c, _d);
				});
			});
		});
	});
}

#endregion