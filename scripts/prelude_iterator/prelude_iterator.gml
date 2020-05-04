/* Iterators (See: `https://github.com/NuxiiGit/gml-prelude`)
 * Kat @Katsaii
 */

/// @desc Creates a reader which returns elements of a ds_grid.
/// @param {ds_grid} id The id of the ds_grid to read.
/// @param {bool} [row_major=true] Whether to iterate in row-major order (`true`), versus column-major order (`false`).
function GridReader(_grid) {
	grid = _grid;
	pos = 0;
	rowMajor = argument_count > 1 ? argument[1] : true;
	Read = function() {
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
	__next__ = Read;
	__seek__ = function(_pos) {
		pos = _pos;
	}
}

/// @desc Creates a reader which returns elements of a ds_list.
/// @param {ds_list} id The id of the ds_list to read.
function ListReader(_list) {
	list = _list;
	pos = 0;
	Read = function() {
		if (pos >= ds_list_size(list)) {
			return undefined;
		}
		var next = list[| pos];
		pos += 1;
		return next;
	}
	__next__ = Read;
	__seek__ = function(_pos) {
		pos = _pos;
	}
}

/// @desc Creates a reader which returns elements of a ds_queue.
/// @param {ds_queue} id The id of the ds_queue to read.
function QueueReader(_queue) {
	queue = _queue;
	Read = function() {
		if (ds_queue_empty(queue)) {
			return undefined;
		}
		return ds_queue_dequeue(queue);
	}
	__next__ = Read;
}

/// @desc Creates a reader which returns elements of a ds_stack.
/// @param {ds_stack} id The id of the ds_stack to read.
function StackReader(_stack) {
	stack = _stack;
	Read = function() {
		if (ds_stack_empty(stack)) {
			return undefined;
		}
		return ds_stack_pop(stack);
	}
	__next__ = Read;
}

/// @desc Creates a reader which returns elements of a ds_priority.
/// @param {ds_priority} id The id of the ds_priority to read.
/// @param {bool} [max=true] Whether to remove values by maximum priority (`true`), versus minimum priority (`false`).
function PriorityQueueReader(_queue) {
	queue = _queue;
	takeMaximum = argument_count > 1 ? argument[1] : true;
	Read = function() {
		if (ds_priority_empty(queue)) {
			return undefined;
		}
		return takeMaximum ? ds_priority_delete_max(queue) : ds_priority_delete_min(queue);
	}
	__next__ = Read;
}

/// @desc Creates a reader which returns key-value pairs of a ds_map.
/// @param {ds_map} id The id of the ds_map to read.
function MapReader(_map) {
	map = _map;
	key = ds_map_find_first(map);
	Read = function() {
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
	__next__ = Read;
	__seek__ = function(_pos) {
		key = ds_map_find_first(map);
		repeat (_pos) {
			if (key == undefined) {
				break;
			}
			key = ds_map_find_next(map, key);
		}
	}
}

/// @desc Creates a reader which returns elements of an array.
/// @param {array} variable The array to read.
function ArrayReader(_array) constructor {
	var count = array_length(_array);
	array = array_create(count);
	array_copy(array, 0, _array, 0, count);
	len = count;
	pos = 0;
	Read = function() {
		if (pos >= len) {
			return undefined;
		}
		var next = array[pos];
		pos += 1;
		return next;
	}
	__next__ = Read;
	__seek__ = function(_pos) {
		pos = _pos;
	}
}

/// @desc Creates a reader which returns individual characters of a string.
/// @param {string} str The string to read.
function CharacterReader(_str) constructor {
	str = _str;
	len = string_length(str);
	pos = 0;
	Read = function() {
		if (pos >= len) {
			return undefined;
		}
		pos += 1;
		return string_char_at(str, pos);
	}
	__next__ = Read;
	__seek__ = function(_pos) {
		pos = _pos;
	}
}

/// @desc Creates an iterator instance with this function.
/// @param {value} variable The data structure or value to generate values from.
/// @param {int} [ds_type] The type of data structure, if `variable` holds a data structure index.
function Iterator(_ds) constructor {
	var reader;
	if (argument_count > 1) {
		var ds_type = argument[1];
		if not (is_real(ds_type)) {
			throw "incompatible data structure index: data structure indexes must be numbers";
		}
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
	/// @desc The seek function.
	seeker = variable_struct_exists(reader, "__seek__") ? reader.__seek__ : undefined;
	/// @desc The peeked value.
	peeked = undefined;
	/// @desc Whether a peeked value exists.
	peekedExists = false;
	/// @desc Advance the iterator and return its Next value.
	Next = function() {
		if (peekedExists) {
			peekedExists = false;
			return peeked;
		} else {
			return generator();
		}
	}
	/// @desc Peek at the Next value in the iterator.
	Peek = function() {
		if not (peekedExists) {
			peeked = generator();
			peekedExists = true;
		}
		return peeked;
	}
	/// @desc Sets the current iterator location.
	Seek = function(_pos) {
		if (seeker == undefined) {
			throw "invalid operation: iterator does not support seeking. implement a `__seek__` method to use this behaviour";
		}
		seeker(_pos);
	}
	/// @desc Resets the iterator.
	Reset = function() {
		Seek(0);
	}
	/// @desc Returns whether the iterator is empty.
	IsEmpty = function() {
		return Peek() == undefined;
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
			if (IsEmpty() || !_p(Peek())) {
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
			if (IsEmpty() || _p(peek)) {
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
			if (IsEmpty() || !_p(Peek())) {
				break;
			}
			Next();
		}
	}
	/// @desc Drops values until some predicate holds.
	/// @param {script} p The predicate to check.
	DropUntil = function(_p) {
		while (true) {
			if (IsEmpty() || _p(Peek())) {
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
		return new Iterator({
			a : _other,
			b : me,
			__next__ : function() {
				if (a.IsEmpty() || b.IsEmpty()) {
					return undefined;
				} else {
					return [a.Next(), b.Next()];
				}
			}
		});
	}
	/// @desc Enumerates this iterator.
	Enumerate = function() {
		return Zip(range(0, infinity));
	}
	/// @desc Flattens a single level of an iterator which returns arrays.
	Concat = function() {
		var me = self;
		return new Iterator({
			iter : me,
			inner : undefined,
			__next__ : function() {
				while (true) {
					if (inner == undefined) {
						if (iter.IsEmpty()) {
							return undefined;
						} else if (inner == undefined) {
							// get new inner value
							var val = iter.Next();
							if (is_struct(val) && variable_struct_exists(val, "__next__") ||
									is_array(val) || is_string(val)) {
								inner = new Iterator(val);
							} else {
								return val;
							}
						}
					}
					// consume inner iterator
					if (inner.IsEmpty()) {
						inner = undefined;
					} else {
						return inner.Next();
					}
				}
			}
		});
	}
	/// @desc Applies a function to the generator of this iterator.
	/// @param {script} f The function to apply.
	Map = function(_f) {
		var me = self;
		return new Iterator({
			iter : me,
			f : _f,
			__next__ : function() {
				if (iter.IsEmpty()) {
					return undefined;
				} else {
					return f(iter.Next());
				}
			}
		});
	}
	/// @desc Joins two iterators together, such that when the first ends the second begins.
	/// @param {script} other The iterator to append onto this one.
	Append = function(_other) {
		var me = self;
		return new Iterator({
			a : me,
			b : _other,
			__next__ : function() {
				return a.IsEmpty() ? b.Next() : a.Next();
			}
		});
	}
	/// @desc Filters out elements of this iterator for which this predicate holds true.
	/// @param {script} p The predicate to check.
	Filter = function(_p) {
		var me = self;
		return new Iterator({
			iter : me,
			p : _p,
			__next__ : function() {
				var val;
				do {
					if (iter.IsEmpty()) {
						return undefined;
					}
					val = iter.Next();
				} until (p(val));
				return val;
			}
		});
	}
	/// @desc Generates values until the iterator is empty, or until an element does not satisfy the predicate.
	/// @param {script} p The predicate to check.
	All = function(_p) {
		DropWhile(_p);
		return IsEmpty();
	}
	/// @desc Generates values until the iterator is empty, or until an element satisfies the predicate.
	/// @param {script} p The predicate to check.
	Any = function(_p) {
		DropUntil(_p);
		if (IsEmpty()) {
			return false;
		} else {
			Next();
			return true;
		}
	}
	/// @desc Applies a left-associative operation to all elements of the iterator.
	/// @param {value} y0 The default value.
	/// @param {script} f The function to apply.
	Fold = function(_y0, _f) {
		var acc = _y0;
		while not (IsEmpty()) {
			var result = _f(acc, Next());
			if (result != undefined) {
				// support for built-in functions, such as `ds_list_add`, which return `undefined`
				acc = result;
			}
		}
		return acc;
	}
	/// @desc Converts an iterator into an array.
	/// @param {value} [type] The type to Fold into. Can be one of: `ds_type_list`, `ds_type_queue`, `ds_type_stack`.
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
		return Fold(y0, f);
	}
	/// @desc Calls a procedure for all elements of the iterator.
	/// @param {script} f The procedure to call.
	ForEach = function(_f) {
		while not (IsEmpty()) {
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
function range(_first, _last) {
	return new Iterator({
		pos : _first,
		len : _last,
		step : argument_count > 2 ? argument[2] : 1,
		__next__ : function() {
			if (pos > len) {
				return undefined;
			}
			var next = pos;
			pos += step;
			return next;
		}
	});
}