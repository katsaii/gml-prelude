/* Iterators (See: `https://github.com/NuxiiGit/gml-prelude`)
 * Kat @Katsaii
 */

/// @desc Creates an iterator instance with this function.
/// @param {script} generator The function which will generate values for the iterator.
function Iterator(_f) constructor {
	generator = _f;
	is_peeked = false;
	peeked = undefined;
}

/// @desc Advance the iterator and return its next value.
/// @param {Iterator} iter The iterator to advance.
function next(_iter) {
	if (_iter.has_peeked) {
		_iter.has_peeked = false;
		return _iter.peeked;
	} else {
		return _iter.generator();
	}
}

/// @desc Peek at the next value in the iterator.
/// @param {Iterator} iter The iterator to peek at the next value of.
function peek(_iter) {
	if not (_iter.has_peeked) {
		_iter.has_peeked = true;
		_iter.peeked = _iter.generator();
	}
	return _iter.peeked;
}

/// @desc Creates an iterator from a struct, array, or function reference.
/// @param {value} variable The value to convert into an iterator.
function iterator(_ref) {
	if (is_struct(_ref)) {
		show_error("not implemented", true);
	} else if (is_array(_ref)) {
		show_error("not implemented", true);
	} else {
		return new Iterator(_ref);
	}
}

/// @desc Creates an iterator from a struct. The method `__iter__` will be
///       called to get the iterator struct. If `__iter__` does not exist,
///       the callee will be used as the target. Then, the `__next__`
///       method will be used to generate values for the iterator.
/// @param {struct} struct The struct to convert into an iterator.
function iterator_from_struct(_struct) {
	var target = variable_struct_exists(_struct, "__iter__") ?
			_struct.__iter__() : _struct;
	var generator = target.__next__;
	return new Iterator(generator);
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