/* Iterator library
 * ----------------
 * Kat @Katsaii
 * `https://github.com/NuxiiGit/gml-prelude`
 */

/// @desc Creates a reader which returns elements of a ds_grid.
/// @param {ds_grid} id The id of the ds_grid to read.
/// @param {bool} [row_major=true] Whether to iterate in row-major order (`true`), versus column-major order (`false`).
function GridReader(_grid) constructor {
	grid = _grid;
	pos = 0;
	rowMajor = argument_count > 1 ? argument[1] : true;
	read = function() {
		var w = ds_grid_width(grid);
		var h = ds_grid_height(grid);
		if (pos >= w * h) {
			return undefined;
		}
		var xord, yord;
		if (rowMajor) {
			xord = pos mod w;
			yord = pos div w;
		} else {
			xord = pos div h;
			yord = pos mod h;
		}
		pos += 1;
		return grid[# xord, yord];
	}
	__next__ = read;
}

/// @desc Creates a reader which returns elements of a ds_list.
/// @param {ds_list} id The id of the ds_list to read.
function ListReader(_list) constructor {
	list = _list;
	pos = 0;
	read = function() {
		if (pos >= ds_list_size(list)) {
			return undefined;
		}
		var val = list[| pos];
		pos += 1;
		return val;
	}
	__next__ = read;
}

/// @desc Creates a reader which returns elements of a ds_queue.
/// @param {ds_queue} id The id of the ds_queue to read.
function QueueReader(_queue) constructor {
	queue = _queue;
	read = function() {
		if (ds_queue_empty(queue)) {
			return undefined;
		}
		return ds_queue_dequeue(queue);
	}
	__next__ = read;
}

/// @desc Creates a reader which returns elements of a ds_stack.
/// @param {ds_stack} id The id of the ds_stack to read.
function StackReader(_stack) constructor {
	stack = _stack;
	read = function() {
		if (ds_stack_empty(stack)) {
			return undefined;
		}
		return ds_stack_pop(stack);
	}
	__next__ = read;
}

/// @desc Creates a reader which returns elements of a ds_priority.
/// @param {ds_priority} id The id of the ds_priority to read.
/// @param {bool} [max=true] Whether to remove values by maximum priority (`true`), versus minimum priority (`false`).
function PriorityQueueReader(_queue) constructor {
	queue = _queue;
	takeMaximum = argument_count > 1 ? argument[1] : true;
	read = function() {
		if (ds_priority_empty(queue)) {
			return undefined;
		}
		return takeMaximum ? ds_priority_delete_max(queue) : ds_priority_delete_min(queue);
	}
	__next__ = read;
}

/// @desc Creates a reader which returns key-value pairs of a ds_map.
/// @param {ds_map} id The id of the ds_map to read.
function MapReader(_map) constructor {
	map = _map;
	key = ds_map_find_first(map);
	read = function() {
		if (key == undefined) {
			return undefined;
		}
		var next_key = key;
		var next_value = map[? key];
		if (next_value == undefined) {
			key = undefined;
			return undefined;
		}
		key = ds_map_find_next(map, key);
		return [next_key, next_value];
	}
	__next__ = read;
}

/// @desc Creates a reader which returns elements of an array.
/// @param {array} variable The array to read.
function ArrayReader(_array) constructor {
	var count = array_length(_array);
	array = array_create(count);
	array_copy(array, 0, _array, 0, count);
	len = count;
	pos = 0;
	read = function() {
		if (pos >= len) {
			return undefined;
		}
		var val = array[pos];
		pos += 1;
		return val;
	}
	__next__ = read;
}

/// @desc Creates a reader which returns individual characters of a string.
/// @param {string} str The string to read.
function CharacterReader(_str) constructor {
	str = _str;
	len = string_length(str);
	pos = 0;
	read = function() {
		if (pos >= len) {
			return undefined;
		}
		pos += 1;
		return string_char_at(str, pos);
	}
	__next__ = read;
}

/// @desc Creates a reader which returns slices of a string separated by a delimiter.
/// @param {string} str The string to read.
/// @param {string} delimiter The string to use as a delimiter.
function WordReader(_str, _delimiter) constructor {
	delimiter = _delimiter;
	str = _str + delimiter;
	len = string_length(delimiter);
	pos = 1;
	read = function() {
		if (str == "") {
			return undefined;
		}
		var val;
		var count = string_pos(delimiter, str) - pos;
		if (count >= 0) {
			val = string_copy(str, pos, count);
			str = string_delete(str, pos, count + len);
		} else {
			val = str;
			str = "";
		}
		return val;
	}
	__next__ = read;
}

/// @desc Creates a reader which returns lines of a file.
/// @param {file} file The file to read.
function FileReader(_file) constructor {
	file = _file;
	read = function() {
		if (file_text_eof(file)) {
			return undefined;
		}
		var line = file_text_read_string(file);
		file_text_readln(file);
		return line;
	}
	__next__ = read;
}

/// @desc Creates an iterator instance from this data structure.
/// @param {value} variable The data structure or value to generate values from.
/// @param {int} [ds_type] The type of data structure, if `variable` holds a data structure index.
function Iterator(_ds) constructor {
	var reader;
	if (argument_count > 1) {
		var ds_type = argument[1];
		switch (ds_type) {
		case ds_type_grid:
			reader = new GridReader(_ds);
			break;
		case ds_type_list:
			reader = new ListReader(_ds);
			break;
		case ds_type_queue:
			reader = new QueueReader(_ds);
			break;
		case ds_type_stack:
			reader = new StackReader(_ds);
			break;
		case ds_type_priority:
			reader = new PriorityQueueReader(_ds);
			break;
		case ds_type_map:
			reader = new MapReader(_ds);
			break;
		default:
			throw "unknown ds_kind (" + string(ds_type) + ")";
		}
	} else if (is_struct(_ds)) {
		reader = _ds;
	} else if (is_array(_ds)) {
		reader = new ArrayReader(_ds);
	} else if (is_string(_ds)) {
		reader = new CharacterReader(_ds);
	} else {
		throw "unsupported data structure (" + string(_ds) + ")";
	}
	if (variable_struct_exists(reader, "__iter__")) {
		reader = reader.__iter__();
	}
	if not (variable_struct_exists(reader, "__next__")) {
		throw "invalid struct format: requires `__next__` method";
	}
	/// @desc The generator function.
	generator = reader.__next__;
	/// @desc The peeked value.
	peeked = undefined;
	/// @desc Whether a peeked value exists.
	peekedExists = false;
	/// @desc Advance the iterator and return its next value.
	next = function() {
		if (peekedExists) {
			peekedExists = false;
			return peeked;
		} else {
			return generator();
		}
	}
	/// @desc peek at the next value in the iterator.
	peek = function() {
		if not (peekedExists) {
			peeked = generator();
			peekedExists = true;
		}
		return peeked;
	}
	/// @desc Takes values.whilst some predicate holds.
	/// @param {script} p The predicate to check.
	takeWhile = function(_p) {
		generator = method({
			g : generator,
			p : _p,
			locked : false
		}, function() {
			if (locked) {
				return undefined;
			}
			var val = g();
			if (val == undefined || !p(val)) {
				locked = true;
				return undefined;
			}
			return val;
		});
		return self;
	}
	/// @desc Takes values.until some predicate holds.
	/// @param {script} p The predicate to check.
	takeUntil = function(_p) {
		return takeWhile(method({
			p : _p
		}, function(_x) {
			return !p(_x);
		}));
	}
	/// @desc Takes the first `n` non-undefined values.
	/// @param {int} n The number of elements to take.
	take = function(_count) {
		return takeWhile(method({
			n : _count
		}, function(_) {
			if (n <= 0) {
				return false;
			} else {
				n -= 1;
				return true;
			}
		}));
	}
	/// @desc Skips values.whilst some predicate holds.
	/// @param {script} p The predicate to check.
	dropWhile = function(_p) {
		generator = method({
			g : generator,
			p : _p,
			locked : false
		}, function() {
			if (locked) {
				return g();
			}
			var val;
			do {
				val = g();
			} until (val == undefined || !p(val));
			locked = true;
			return val;
		});
		return self;
	}
	/// @desc Skips values.until some predicate holds.
	/// @param {script} p The predicate to check.
	dropUntil = function(_p) {
		return dropWhile(method({
			p : _p
		}, function(_x) {
			return !p(_x);
		}));
	}
	/// @desc Skips the first `n` non-undefined values.
	/// @param {int} n The number of elements to drop.
	drop = function(_count) {
		return dropWhile(method({
			n : _count
		}, function(_) {
			if (n <= 0) {
				return false;
			} else {
				n -= 1;
				return true;
			}
		}));
	}
	/// @desc Applies a function to the generator of this iterator.
	/// @param {script} f The function to apply.
	map = function(_f) {
		generator = method({
			g : generator,
			f : _f
		}, function() {
			var val = g();
			if (val == undefined) {
				return undefined;
			}
			return f(val);
		});
		return self;
	}
	/// @desc Filters out elements of this iterator for which this predicate holds true.
	/// @param {script} p The predicate to check.
	filter = function(_p) {
		generator = method({
			g : generator,
			p : _p
		}, function() {
			var val;
			do {
				val = g();
			} until (val == undefined || p(val));
			return val;
		});
		return self;
	}
	/// @desc Zips this iterator together with another.
	/// @param {Iterator} other The iterator to join this with.
	zip = function(_other) {
		generator = method({
			a : generator,
			b : _other.generator
		}, function() {
			var val_a = a();
			var val_b = b();
			if (val_a == undefined || val_b == undefined) {
				return undefined;
			} else {
				return [val_a, val_b]; 
			}
		});
		return self;
	}
	/// @desc Enumerates this iterator.
	enumerate = function() {
		return zip(range(0, infinity));
	}
	/// @desc Appends another iterator onto the end of this iterator.
	/// @param {script} other The iterator to append onto this one.
	extend = function(_other) {
		generator = method({
			a : generator,
			b : _other.generator,
			locked : false
		}, function() {
			if (locked) {
				return b();
			}
			var val = a();
			if (val == undefined) {
				locked = true;
				return b();
			}
			return val;
		});
		return self;
	}
	/// @desc Returns the first element where this predicate holds.
	/// @param {script} p The predicate to check.
	first = function(_p) {
		dropUntil(_p);
		return next();
	}
	/// @desc Returns the "nth" element of this iterator, starts at zero.
	/// @param {script} n The index of the item of obtain.
	nth = function(_n) {
		drop(_n);
		return next();
	}
	/// @desc Generates values until the iterator is empty, or until an element does not satisfy the predicate.
	///       `true` is returned if all elements satisfy the predicate, and `false` is returned otherwise.
	/// @param {script} p The predicate to check.
	each = function(_p) {
		var val = first(method({
			p : _p
		}, function(_x) {
			return !p(_x);
		}));
		return val == undefined;
	}
	/// @desc Generates values until the iterator is empty, or until an element satisfies the predicate.
	///       `true` is returned if any element satisfies the predicate, and `false` is returned otherwise.
	/// @param {script} p The predicate to check.
	some = function(_p) {
		var val = first(_p);
		return val != undefined;
	}
	/// @desc Calls a procedure for all elements of the iterator.
	/// @param {script} ind The procedure to call.
	forEach = function(_f) {
		while (true) {
			var val = next();
			if (val == undefined) {
				break;
			}
			_f(val);
		}
	}
	/// @desc Applies a left-associative operation to all elements of the iterator.
	/// @param {value} y0 The default value.
	/// @param {script} f The function to apply.
	fold = function(_y0, _f) {
		for (var acc = _y0; true;) {
			var val = next();
			if (val == undefined) {
				return acc;
			}
			var result = _f(acc, val);
			if (result != undefined) {
				// support for built-in functions, such as `ds_list_add`, which return `undefined`
				acc = result;
			}
		}
	}
	/// @desc Converts an iterator into an array.
	/// @param {value} [ds_type] The type to fold into. Can be one of: `ds_type_list`, `ds_type_queue`, `ds_type_stack`.
	collect = function() {
		var y0, f;
		if (argument_count > 0) {
			var ds_type = argument[0];
			if (ds_type == ds_type_list) {
				y0 = ds_list_create();
				f = method(undefined, ds_list_add);
			} else if (ds_type == ds_type_queue) {
				y0 = ds_queue_create();
				f = method(undefined, ds_queue_enqueue);
			} else if (ds_type == ds_type_stack) {
				y0 = ds_stack_create();
				f = method(undefined, ds_stack_push);
			} else {
				throw "unsupported collection type";
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
	/// @desc Adds elements of this iterator together.
	/// @param {number} type The type of elements to sum.
	sum = function(_type) {
		var y0, f;
		if (_type == ty_real) {
			y0 = 0;
			f = function(_xs, _x) {
				var val;
				if (is_real(_x)) {
					val = _x;
				} else {
					try {
						val = real(_x);
					} catch (_) {
						throw "incompatible number type";
					}
				}
				return _xs + val;
			};
		} else if (_type == ty_string) {
			y0 = "";
			f = function(_xs, _x) {
				var val;
				if (is_string(_x)) {
					val = _x;
				} else {
					val = string(_x);
				}
				return _xs + val;
			};
		} else {
			throw "unsupported sum type: must be `ty_real` or `ty_string`";
		}
		return fold(y0, f);
	}
	/// @desc Multiplies elements of this iterator together.
	product = function() {
		return fold(1, function(_xs, _x) {
			var val;
			if (is_real(_x)) {
				val = _x;
			} else {
				try {
					val = real(_x);
				} catch (_) {
					throw "incompatible number type";
				}
			}
			return _xs * val;
		});
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
		return "[ " + str + " ]";
	}
}

/// @desc Produces an iterator which spans over a range.
/// @param {real} first The first element of the range.
/// @param {real} last The last element of the range.
/// @param {real} [step=1] The step of the range.
function range(_first, _last) {
	return new Iterator({
		pos : _first,
		len : _last,
		step : argument_count > 2 ? argument[2] : 1,
		__next__ : function() {
			if (pos > len) {
				return undefined;
			}
			var val = pos;
			pos += step;
			return val;
		}
	});
}

/// @desc Produces an iterator which repetitively applies some function to an initial value.
/// @param {value} value The first element of the sequence.
/// @param {script} f The function to apply.
function iterate(_first, _f) {
	return new Iterator({
		acc : _first,
		f : _f,
		__next__ : function() {
			var val = acc;
			acc = f(acc);
			return val;
		}
	});
}