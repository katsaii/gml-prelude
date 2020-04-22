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
	var arr = [];
	try {
		for (var i = 0; true; i += 1) {
			arr[@ i] = next(_iter);
		}
	} catch (_exception) {
		if (instanceof(_exception) != "StopIteration")
		then throw _exception;
	}
	return arr;
}

#endregion

#region array

/// @desc Applies a function to all elements of an array and returns a new array.
/// @param {array} variable The array to apply the function to.
/// @param {script} f The function to apply to all elements in the array.
/// @param {int} [n] The size of the output array.
/// @param {int} [i=0] The index of the array to start at.
function array_mapf(_arr, _f) {
	var n = argument_count > 2 ? argument[2] : array_length(_arr);
	var i = argument_count > 3 ? argument[3] : 0;
	var clone = array_create(n);
	for (var j = 0; j < n; j += 1) {
		clone[@ j] = _f(_arr[j + i]);
	}
	return clone;
}

/// @desc Calls some procedure for each element of an array.
/// @param {array} variable The array to apply the function to.
/// @param {script} f The function to apply to all elements in the array.
/// @param {int} [n] The number of elements to loop through.
/// @param {int} [i=0] The index of the array to start at.
function array_foreach(_arr, _f) {
	var n = argument_count > 2 ? argument[2] : array_length(_arr);
	var i = argument_count > 3 ? argument[3] : 0;
	for (; i < n; i += 1) {
		_f(_arr[i]);
	}
}

/// @desc Converts an array into an iterator.
function array_into_iterator(_arr) {
	return new Iterator({
		arr : _arr,
		pos : 0,
		len : array_length(_arr),
		next : function() {
			if (pos < len) {
				var val = arr[pos];
				pos += 1;
				return val;
			} else {
				throw new StopIteration();
			}
		}
	});
}

#endregion

#region currying

function curry_pair(_f) {
	return method({
		func : _f
	}, function(_a) {
		return method({
			func : self.func,
			a : _a
		}, function(_b) {
			return func(a, _b);
		});
	});
}

#endregion