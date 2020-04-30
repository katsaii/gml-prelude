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
	} else if (is_string(generator)) {
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
			var item = peeked;
			peeked = undefined;
			return item;
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
			array[@ i] = next();
		}
		return array;
	}
	/// @desc Drops the first `n` values from this iterator.
	/// @param {int} n The number of elements to drop.
	drop = function(_count) {
		repeat (_count) {
			next();
		}
	}
	/// @desc Zips this iterator together with another.
	/// @param {Iterator} other The iterator to join this with.
	zip = function(_other) {
		var me = self;
		return new Iterator(method({
			a : _other,
			b : me
		}, function() {
			if (a.peek() == undefined ||
					b.peek() == undefined) {
				return undefined;
			} else {
				return [a.next(), b.next()];
			}
		}));
	}
	/// @desc Enumerates this iterator.
	enumerate = function() {
		return zip(iterator_range(0, infinity));
	}
	/// @desc Flattens a single level of an iterator which returns arrays.
	concat = function() {
		return new Iterator(method({
			next : self.next,
			pos : 0,
			len : 0,
			val : []
		}, function() {
			if (pos >= len) {
				do {
					val = next();
					if not (is_array(val)) {
						val = [val];
					}
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
	map = function(_f) {
		return new Iterator(method({
			next : self.next,
			f : _f
		}, function() {
			var val = next();
			return val == undefined ? undefined : f(val);
		}));
	}
	/// @desc Filters out elements of this iterator for which this predicate holds true.
	/// @param {script} p The predicate to check.
	filter = function(_p) {
		return new Iterator(method({
			next : self.next,
			p : _p
		}, function() {
			var val;
			do {
				val = next();
				if (val == undefined) {
					return undefined;
				}
			} until (p(val));
			return val;
		}));
	}
	/// @desc Applies a left-associative operation to all elements of the iterator.
	/// @param {value} y0 The default value.
	/// @param {script} f The function to apply.
	fold = function(_y0, _f) {
		var acc = _y0;
		while (peek() != undefined) {
			var result = _f(acc, next());
			if (result != undefined) {
				// support for built-in functions, such as `ds_list_add`, which return `undefined`
				acc = result;
			}
		}
		return acc;
	}
	/// @desc Converts an iterator into an array.
	/// @param {value} [ds_type] The ds_type to fold into. Can be one of: `ds_type_list`, `ds_type_queue`, or `ds_type_stack`.
	collect = function() {
		var y0, f;
		if (argument_count > 0) {
			switch (argument[0]) {
			case ds_type_list:
				y0 = ds_list_create();
				f = method(undefined, ds_list_add);
				break;
			case ds_type_queue:
				y0 = ds_queue_create();
				f = method(undefined, ds_queue_enqueue);
				break;
			case ds_type_stack:
				y0 = ds_stack_create();
				f = method(undefined, ds_stack_push);
				break;
			default:
				show_error("unsupported ds type", false);
				break;
			}
		} else {
			y0 = [];
			f = method({
				pos : 0
			}, function(_xs, _x) {
				_xs[@ pos] = _x;
				pos += 1;
				return _xs;
			});
		}
		return fold(y0, f);
	}
	/// @desc Calls a procedure for all elements of the iterator.
	/// @param {script} f The procedure to call.
	foreach = function(_f) {
		while (peek() != undefined) {
			_f(next());
		}
	}
	/// @desc Converts an iterator into a string.
	toString = function() {
		var str = fold("", function(_xs, _x) {
			var msg = _xs;
			if (msg != "") {
				msg += ", ";
			}
			if (is_string(_x)) {
				msg += "\"" + string_replace_all(_x, "\"", "\\\"") + "\"";
			} else {
				msg += string(_x);
			}
			return msg;
		});
		return "[" + str + "]";
	}
}

/// @desc Produces an iterator which spans over a range.
/// @param {real} first The first element of the range.
/// @param {real} last The last element of the range.
/// @param {real} [step=1] The step of the range.
function iterator_range(_first, _last) {
	return new Iterator(method({
		pos : _first,
		len : _last,
		step : argument_count > 2 ? argument[2] : 1,
	}, function() {
		if (pos <= len) {
			var n = pos;
			pos += step;
			return n;
		} else {
			return undefined;
		}
	}));
}