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
	/// @desc Advance the iterator and return its Next value.
	Next = function() {
		if (peeked == undefined) {
			return generator();
		} else {
			var item = peeked;
			peeked = undefined;
			return item;
		}
	}
	/// @desc Peek at the Next value in the iterator.
	Peek = function() {
		if (peeked == undefined) {
			peeked = generator();
		}
		return peeked;
	}
	/// @desc Takes the First `n` values from this iterator and puts them into an array.
	/// @param {int} n The number of elements to Take.
	Take = function(_count) {
		var array = array_create(_count);
		for (var i = 0; i < _count; i += 1) {
			array[@ i] = Next();
		}
		return array;
	}
	/// @desc Takes values and inserts them into an array whilst some predicate holds.
	/// @param {script} p The predicate to check.
	TakeWhile = function(_p) {
		var array = [];
		for (var i = 0; true; i += 1) {
			var peek = Peek();
			if (peek == undefined || !_p(peek)) {
				break;
			}
			array[@ i] = Next();
		}
		return array;
	}
	/// @desc Takes values and inserts them into an array until some predicate holds.
	/// @param {script} p The predicate to check.
	TakeUntil = function(_p) {
		var array = [];
		for (var i = 0; true; i += 1) {
			var peek = Peek();
			if (peek == undefined || _p(peek)) {
				break;
			}
			array[@ i] = Next();
		}
		return array;
	}
	/// @desc Drops the First `n` values from this iterator.
	/// @param {int} n The number of elements to Drop.
	Drop = function(_count) {
		repeat (_count) {
			Next();
		}
	}
	/// @desc Drops values whilst some predicate holds.
	/// @param {script} p The predicate to check.
	DropWhile = function(_p) {
		while (true) {
			var peek = Peek();
			if (peek == undefined || !_p(peek)) {
				break;
			}
			Next();
		}
	}
	/// @desc Drops values until some predicate holds.
	/// @param {script} p The predicate to check.
	DropUntil = function(_p) {
		while (true) {
			var peek = Peek();
			if (peek == undefined || _p(peek)) {
				break;
			}
			Next();
		}
	}
	/// @desc Returns the First element where this predicate holds.
	/// @param {script} p The predicate to check.
	First = function(_p) {
		DropUntil(_p);
		return Next();
	}
	/// @desc Zips this iterator together with another.
	/// @param {Iterator} other The iterator to join this with.
	Zip = function(_other) {
		var me = self;
		return new Iterator(method({
			a : _other,
			b : me
		}, function() {
			if (a.Peek() == undefined ||
					b.Peek() == undefined) {
				return undefined;
			} else {
				return [a.Next(), b.Next()];
			}
		}));
	}
	/// @desc Enumerates this iterator.
	Enumerate = function() {
		return Zip(iterator_range(0, infinity));
	}
	/// @desc Flattens a single level of an iterator which returns arrays.
	Concat = function() {
		return new Iterator(method({
			Next : self.Next,
			pos : 0,
			len : 0,
			val : []
		}, function() {
			if (pos >= len) {
				do {
					val = Next();
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
	Map = function(_f) {
		return new Iterator(method({
			Next : self.Next,
			f : _f
		}, function() {
			var val = Next();
			return val == undefined ? undefined : f(val);
		}));
	}
	/// @desc Filters out elements of this iterator for which this predicate holds true.
	/// @param {script} p The predicate to check.
	Filter = function(_p) {
		return new Iterator(method({
			Next : self.Next,
			p : _p
		}, function() {
			var val;
			do {
				val = Next();
				if (val == undefined) {
					return undefined;
				}
			} until (p(val));
			return val;
		}));
	}
	/// @desc Generates values until the iterator is empty, or until an element does not satisfy the predicate.
	/// @param {script} p The predicate to check.
	All = function(_p) {
		while (Peek() != undefined) {
			if (!_p(Next())) {
				return false;
			}
		}
		return true;
	}
	/// @desc Generates values until the iterator is empty, or until an element satisfies the predicate.
	/// @param {script} p The predicate to check.
	Any = function(_p) {
		while (Peek() != undefined) {
			if (_p(Next())) {
				return true;
			}
		}
		return false;
	}
	/// @desc Applies a left-associative operation to all elements of the iterator.
	/// @param {value} y0 The default value.
	/// @param {script} f The function to apply.
	Fold = function(_y0, _f) {
		var acc = _y0;
		while (Peek() != undefined) {
			var result = _f(acc, Next());
			if (result != undefined) {
				// support for built-in functions, such as `ds_list_add`, which return `undefined`
				acc = result;
			}
		}
		return acc;
	}
	/// @desc Converts an iterator into an array.
	/// @param {value} [ds_type] The ds_type to Fold into. Can be one of: `ds_type_list`, `ds_type_queue`, or `ds_type_stack`.
	Collect = function() {
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
		return Fold(y0, f);
	}
	/// @desc Calls a procedure for all elements of the iterator.
	/// @param {script} f The procedure to call.
	ForEach = function(_f) {
		while (Peek() != undefined) {
			_f(Next());
		}
	}
	/// @desc Converts an iterator into a string.
	toString = function() {
		var str = Fold("", function(_xs, _x) {
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
/// @param {real} First The First element of the range.
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