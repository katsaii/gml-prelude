/* Iterators (See: `https://github.com/NuxiiGit/gml-prelude`)
 * Kat @Katsaii
 */

/// @desc Creates an iterator instance with this function.
/// @param {script} generator The function which will generate values for the iterator.
function Iterator(_f) constructor {
	generator = _f;
	has_peeked = false;
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

/// @desc Creates an iterator from a struct, array, or function reference.
/// @param {value} variable The value to convert into an iterator.
function iterator(_ref) {
	if (is_struct(_ref)) {
		return iterator_from_struct(_ref);
	} else if (is_array(_ref)) {
		return iterator_from_array(_ref);
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

/// @desc Creates an iterator from an array.
/// @param {array} variable The array to convert into an iterator.
function iterator_from_array(_array) {
	var count = array_length(_array)
	var array = array_create(count);
	array_copy(array, 0, _array, 0, count);
	var generator = method({
		array : array,
		count : count,
		pos : 0
	}, function() {
		if (pos < count) {
			var item = array[pos];
			pos += 1;
			return item;
		} else {
			throw new StopIteration();
		}
	});
	return new Iterator(generator);
}