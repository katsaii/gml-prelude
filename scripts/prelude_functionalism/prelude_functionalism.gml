/* Functional Programming Library by Kat @Katsaii
 * `https://github.com/NuxiiGit/functionalism`
 * Kat @Katsaii
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

#endregion