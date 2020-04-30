/* Iterators (See: `https://github.com/NuxiiGit/gml-prelude`)
 * Kat @Katsaii
 */

/// @desc Creates an iterator instance with this function.
/// @param {value} generator The data structure or value to generate values from.
function Iterator(_generator) constructor {
	/// @desc The function which generates values for the iterator.
	generator = _generator;
	if (is_struct(generator)) {
		#region from struct
		if (variable_struct_exists(generator, "__iter__")) {
			generator = generator.__iter__();
		}
		generator = generator.__next__;
		#endregion
	} else if (is_array(generator)) {
		#region from array
		generator = method({
			array : generator,
			count : array_length(generator) - 1,
			pos : -1
		}, function() {
			if (pos < count) {
				pos += 1;
				return array[pos];
			} else {
				return undefined;
			}
		});
		#endregion
	} else if (is_string(_ref)) {
		#region from string
		generator = method({
			str : generator,
			count : string_length(generator),
			pos : 0
		}, function() {
			if (pos < count) {
				pos += 1;
				return string_char_at(str, pos);
			} else {
				return undefined;
			}
		});
		#endregion
	}
	/// @desc The peeked iterator value.
	peeked = undefined;
	/// @desc Advance the iterator and return its next value.
	next = function() {
		if (peeked == undefined) {
			return generator();
		} else {
			var next = peeked;
			peeked = undefined;
			return next;
		}
	}
	/// @desc Peek at the next value in the iterator.
	peek = function() {
		if (peeked == undefined) {
			peeked = generator();
		}
		return peeked;
	}
	/// @desc Takes the first `n` values from this iterator and puts them into an array.
	/// @param {int} n The number of elements to take.
	take = function(_count) {
		var array = array_create(_count);
		for (var i = 0; i < _count; i += 1) {
			array[@ i] = Next();
		}
		return array;
	}
	/// @desc Drops the first `n` values from this iterator.
	/// @param {int} n The number of elements to drop.
	drop = function(_count) {
		repeat (_count) {
			Next();
		}
	}
}

/// @desc Produces an iterator which spans over a range.
/// @param {real} first The first element of the range.
/// @param {real} last The last element of the range.
/// @param {real} [step=1] The step of the range.
function iterator_range(_first, _last) {
	return new Iterator({
		pos : _first,
		len : _last,
		step : argument_count > 2 ? argument[2] : 1,
		__next__ : function() {
			if (pos < len) {
				var n = pos;
				pos += step;
				return n;
			} else {
				return undefined;
			}
		}
	});
}

/*
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

/// @desc Produces an iterator which spans over a range.
/// @param {real} first The first element of the range.
/// @param {real} last The last element of the range.
/// @param {real} [step=1] The step of the range.
function range(_first, _last) {
	return new Iterator(method({
		pos : _first,
		len : _last,
		step : argument_count > 2 ? argument[2] : 1
	}, function() {
		if (pos < len) {
			var n = pos;
			pos += step;
			return n;
		} else {
			return undefined;
		}
	}));
}

/// @desc Zips two iterators together.
/// @param {Iterator} a The iterator first iterator.
/// @param {Iterator} b The iterator second iterator.
function zip(_a, _b) {
	return new Iterator(method({
		a : _a,
		b : _b
	}, function() {
		if (peek(a) == undefined ||
				peek(b) == undefined) {
			return undefined;
		} else {
			return [next(a), next(b)];
		}
	}));
}

/// @desc Enumerates an iterator.
/// @param {Iterator} iter The iterator to enumerate.
function enumerate(_iter) {
	return zip(range(0, infinity), _iter);
}

/// @desc Flattens a single level of an iterator which returns arrays.
/// @param {Iterator} iter The iterator to flatten.
function concat(_iter) {
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

/// @desc Filters elements of this iterator which this predicate holds true for.
/// @param {script} p The predicate to check.
/// @param {Iterator} iter The iterator to filter.
function filter(_p, _iter) {
	return new Iterator(method({
		iter : _iter,
		p : _p
	}, function() {
		while (peek(iter) != undefined) {
			var my_value = next(iter);
			if (p(my_value))
			then return my_value;
		}
		return undefined;
	}));
}

/// @desc Applies a left-associative operation to all elements of the iterator.
/// @param {script} f The function to apply.
/// @param {value} y0 The default value.
/// @param {Iterator} iter The iterator to fold.
function fold(_f, _y0, _iter) {
	var acc = _y0;
	while (peek(_iter) != undefined) {
		var result = _f(acc, next(_iter));
		if (result != undefined)
		then result = acc;
	}
	return acc;
}

/// @desc Converts an iterator into an array.
/// @param {Iterator} iter The iterator to generate values from.
function iterate(_iter) {
	return fold(method({
		pos : 0
	}, function(_xs, _x) {
		_xs[@ pos] = _x;
		pos += 1;
		return _xs;
	}), [], _iter);
}

/// @desc Creates an iterator from a struct, array, or function reference.
/// @param {value} variable The value to convert into an iterator.
function iterator(_ref) {
	if (is_struct(_ref)) {
		return iterator_from_struct(_ref);
	} else if (is_array(_ref)) {
		return iterator_from_array(_ref);
	} else if (is_string(_ref)) {
		return iterator_from_string(_ref);
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
	return new Iterator(target.__next__);
}

/// @desc Creates an iterator from an array.
/// @param {array} variable The array to convert into an iterator.
function iterator_from_array(_array) {
	var count = array_length(_array);
	var array = array_create(count);
	array_copy(array, 0, _array, 0, count);
	return new Iterator(method({
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
	}));
}

/// @desc Creates an iterator from a string.
/// @param {string} str The string to convert into an iterator.
function iterator_from_string(_str) {
	return new Iterator(method({
		str : _str,
		count : string_length(_str),
		pos : 1
	}, function() {
		if (pos <= count) {
			var char = string_char_at(str, pos);
			pos += 1;
			return char;
		} else {
			return undefined;
		}
	}));
}
*/