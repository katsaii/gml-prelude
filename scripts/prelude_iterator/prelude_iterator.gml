/* Iterators (See: `https://github.com/NuxiiGit/gml-prelude`)
 * Kat @Katsaii
 */

/// @desc Creates an iterator instance with this function.
/// @param {value} generator The data structure or value to generate values from.
function Iterator(_generator) constructor {
	peeked = undefined;
	generator = _generator;
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
			var next = pos;
			pos += step;
			return next;
		} else {
			return undefined;
		}
	}));
}

/// @desc Produces an iterator from a ds_grid in column major order.
/// @param {ds_grid} id The id of the ds_grid to convert into an iterator.
function iterator_from_grid_column_major(_grid) {
	return new Iterator(method({
		grid : _grid,
		pos : 0
	}, function() {
		var w = ds_grid_width(grid);
		var h = ds_grid_height(grid);
		if (pos < w * h) {
			var xord = pos div h;
			var yord = pos mod h;
			var next = grid[# xord, yord];
			pos += 1;
			return next;
		} else {
			return undefined;
		}
	}));
}

/// @desc Produces an iterator from a ds_grid in row major order.
/// @param {ds_grid} id The id of the ds_grid to convert into an iterator.
function iterator_from_grid_row_major(_grid) {
	return new Iterator(method({
		grid : _grid,
		pos : 0
	}, function() {
		var w = ds_grid_width(grid);
		var h = ds_grid_height(grid);
		if (pos < w * h) {
			var xord = pos mod w;
			var yord = pos div w;
			var next = grid[# xord, yord];
			pos += 1;
			return next;
		} else {
			return undefined;
		}
	}));
}

/// @desc Produces an iterator from a ds_list.
/// @param {ds_list} id The id of the ds_list to convert into an iterator.
function iterator_from_list(_list) {
	return new Iterator(method({
		list : _list,
		pos : 0
	}, function() {
		if (pos < ds_list_size(list)) {
			var next = list[| pos];
			pos += 1;
			return next;
		} else {
			return undefined;
		}
	}));
}

/// @desc Produces an iterator over values of a ds_queue.
/// @param {ds_queue} id The id of the ds_queue to convert into an iterator.
function iterator_from_queue(_queue) {
	return new Iterator(method({
		queue : _queue
	}, function() {
		if not (ds_queue_empty(queue)) {
			return ds_queue_dequeue(queue);
		} else {
			return undefined;
		}
	}));
}

/// @desc Produces an iterator over values of a ds_stack.
/// @param {ds_stack} id The id of the ds_stack to convert into an iterator.
function iterator_from_stack(_stack) {
	return new Iterator(method({
		stack : _stack
	}, function() {
		if not (ds_stack_empty(stack)) {
			return ds_stack_pop(stack);
		} else {
			return undefined;
		}
	}));
}

/// @desc Produces an iterator over minimum values of a ds_priority.
/// @param {ds_priority} id The id of the ds_priority to convert into an iterator.
function iterator_from_priority_min(_priority_queue) {
	return new Iterator(method({
		queue : _priority_queue
	}, function() {
		if not (ds_priority_empty(queue)) {
			return ds_priority_delete_min(queue);
		} else {
			return undefined;
		}
	}));
}

/// @desc Produces an iterator over maximum values of a ds_priority.
/// @param {ds_priority} id The id of the ds_priority to convert into an iterator.
function iterator_from_priority_max(_priority_queue) {
	return new Iterator(method({
		queue : _priority_queue
	}, function() {
		if not (ds_priority_empty(queue)) {
			return ds_priority_delete_max(queue);
		} else {
			return undefined;
		}
	}));
}

/// @desc Produces an iterator from a struct.
/// @param {struct} struct The struct to convert into an iterator.
function iterator_from_struct(_struct) {
	var template = _struct;
	if (variable_struct_exists(template, "__iter__")) {
		template = template.__iter__();
	}
	return new Iterator(template.__next__);
}

/// @desc Produces an iterator which generates values over an array.
/// @param {array} variable The array to convert into an iterator.
function iterator_from_array(_src) {
	var count = array_length(_src);
	var array = array_create(count);
	array_copy(array, 0, _src, 0, count);
	return new Iterator(method({
		array : array,
		count : count - 1,
		pos : -1
	}, function() {
		if (pos < count) {
			pos += 1;
			return array[pos];
		} else {
			return undefined;
		}
	}));
}

/// @desc Produces an iterator which generates characters over a string.
/// @param {string} str The string to convert into an iterator.
function iterator_from_string(_str) {
	return new Iterator(method({
		str : _str,
		count : string_length(_str),
		pos : 0
	}, function() {
		if (pos < count) {
			pos += 1;
			return string_char_at(str, pos);
		} else {
			return undefined;
		}
	}));
}

/// @desc Produces an iterator which lazily generates values from a function.
/// @param {script} f The generator function of the iterator.
function iterator_from_method(_f) {
	return new Iterator(_f);
}

/// @desc Produces an iterator depending on the type of the input.
/// @param {value} variable The variable which stores the data structure you want to convert into an interator.
/// @param {int} [ds_type] The type of data structure, if `variable` holds a data structure index.
function iterator(_ds) {
	if (argument_count > 1) {
		var ds_type = argument[1];
		if not (is_real(ds_type)) {
			show_error("incompatible data structure index: data structure indexes must be numbers", false);
		}
		switch (ds_type) {
		case ds_type_grid:
			return iterator_from_grid_row_major(_ds);
		case ds_type_list:
			return iterator_from_list(_ds);
		case ds_type_queue:
			return iterator_from_queue(_ds);
		case ds_type_stack:
			return iterator_from_stack(_ds);
		case ds_type_priority:
			return iterator_from_priority_max(_ds);
		default:
			show_error("unknown ds_kind (" + string(ds_type) + ")", false);
		}
	} else if (is_struct(_ds)) {
		return iterator_from_struct(_ds);
	} else if (is_array(_ds)) {
		return iterator_from_array(_ds);
	} else if (is_string(_ds)) {
		return iterator_from_string(_ds);
	} else {
		return iterator_from_method(_ds);
	}
}