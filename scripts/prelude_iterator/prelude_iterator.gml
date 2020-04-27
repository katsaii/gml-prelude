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

/// @desc Takes the first `n` values from this iterator and puts them into an array.
/// @param {int} n The number of elements to take.
/// @param {Iterator} iter The iterator to generate values from.
function take(_count, _iter) {
	var array = array_create(_count);
	for (var i = 0; i < _count; i += 1) {
		array[@ i] = next(_iter);
	}
	return array;
}

/// @desc Drops the first `n` values from this iterator.
/// @param {Iterator} iter The iterator to generate values from.
/// @param {int} n The number of elements to drop.
function drop(_count, _iter) {
	repeat (_count) {
		next(_iter);
	}
}

/// @desc Enumerates an iterator.
/// @param {Iterator} iter The iterator to enumerate.
function enumerate(_iter) {
	return new Iterator(method({
		iter : _iter,
		pos : 0
	}, function() {
		var my_pos = pos;
		var my_value = next(iter);
		if (my_value == undefined) {
			return undefined;
		} else {
			pos += 1;
			return [my_pos, my_value];
		}
	}));
}

/// @desc Flattens a single level of an iterator which returns arrays.
/// @param {Iterator} iter The iterator to flatten.
function flatten(_iter) {
	return new Iterator(method({
		iter : _iter,
		pos : 0,
		len : 0,
		val : []
	}, function() {
		if (pos >= len) {
			do {
				val = next(iter);
				if not (is_array(val))
				then val = [val];
				len = array_length(val);
			} until (len > 0);
			pos = 0;
		}
		var i = pos;
		pos += 1;
		return val[i];
	}));
}

/// @desc Applies a function to the generator of this iterator.
/// @param {script} f The function to apply.
/// @param {Iterator} iter The iterator to map.
function mapf(_f, _iter) {
	return new Iterator(method({
		iter : _iter,
		f : _f
	}, function() {
		var my_value = next(iter);
		return my_value == undefined ? undefined : f(my_value);
	}));
}

/// @desc Converts an iterator into an array.
/// @param {Iterator} iter The iterator to generate values from.
function iterate(_iter) {
	var array = [];
	for (var i = 0; peek(_iter) != undefined; i += 1) {
		array[@ i] = next(_iter);
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
			return undefined;
		}
	});
	return new Iterator(generator);
}