/* Higher order functions (See: `https://github.com/NuxiiGit/functionalism`)
 * Kat @Katsaii
 */

/// @desc Converts a built-in function into a usable function pointer.
/// @param {function} name The name of the built-in function to obtain.
function func_ptr(_name) {
	return method({}, _name);
}

/// @desc The identity function. Returns the input value.
/// @param {value} value The value to return.
function identity(_x) {
	return _x;
}

/// @desc Calls a function using an array as the parameter array.
/// @param {script} ind The id of the script to call.
/// @param {array} variable The id of the array to pass as a parameter array to this script.
function script_execute_array(_f, _a) {
	switch(array_length(_a)){
	case 0: return _f();
	case 1: return _f(_a[0]);
	case 2: return _f(_a[0], _a[1]);
	case 3: return _f(_a[0], _a[1], _a[2]);
	case 4: return _f(_a[0], _a[1], _a[2], _a[3]);
	case 5: return _f(_a[0], _a[1], _a[2], _a[3], _a[4]);
	case 6: return _f(_a[0], _a[1], _a[2], _a[3], _a[4], _a[5]);
	case 7: return _f(_a[0], _a[1], _a[2], _a[3], _a[4], _a[5], _a[6]);
	case 8: return _f(_a[0], _a[1], _a[2], _a[3], _a[4], _a[5], _a[6], _a[7]);
	case 9: return _f(_a[0], _a[1], _a[2], _a[3], _a[4], _a[5], _a[6], _a[7], _a[8]);
	case 10: return _f(_a[0], _a[1], _a[2], _a[3], _a[4], _a[5], _a[6], _a[7], _a[8], _a[9]);
	case 11: return _f(_a[0], _a[1], _a[2], _a[3], _a[4], _a[5], _a[6], _a[7], _a[8], _a[9], _a[10]);
	case 12: return _f(_a[0], _a[1], _a[2], _a[3], _a[4], _a[5], _a[6], _a[7], _a[8], _a[9], _a[10], _a[11]);
	case 13: return _f(_a[0], _a[1], _a[2], _a[3], _a[4], _a[5], _a[6], _a[7], _a[8], _a[9], _a[10], _a[11], _a[12]);
	case 14: return _f(_a[0], _a[1], _a[2], _a[3], _a[4], _a[5], _a[6], _a[7], _a[8], _a[9], _a[10], _a[11], _a[12], _a[13]);
	case 15: return _f(_a[0], _a[1], _a[2], _a[3], _a[4], _a[5], _a[6], _a[7], _a[8], _a[9], _a[10], _a[11], _a[12], _a[13], _a[14]);
	case 16: return _f(_a[0], _a[1], _a[2], _a[3], _a[4], _a[5], _a[6], _a[7], _a[8], _a[9], _a[10], _a[11], _a[12], _a[13], _a[14], _a[15]);
	default: show_error("argument count of " + string(array_length(_a)) + " is not supported", false);
	}
}

/// @desc Generates a new curried function.
/// @param {int} arg_count The number of arguments to curry.
/// @param {script} ind the id of the script to apply currying to.
function CurriedFunction(_count, _f) constructor {
	count = _count;
	pos = 0;
	f = _f;
	closure = array_create(count, undefined);
	call = function() {
		var param_count = argument_count;
		var params = array_create(param_count);
		for (var i = param_count - 1; i >= 0; i -= 1) {
			params[@ i] = argument[i];
		}
		if (pos < count) {
			var child = new CurriedFunction(count, f);
			child.pos = pos + 1;
			array_copy(child.closure, 0, closure, 0, pos);
			child.closure[@ pos] = param_count == 1 ? params[0] : params;
			return child.call;
		} else {
			var arguments = array_create(count + param_count);
			array_copy(arguments, 0, closure, 0, count);
			array_copy(arguments, count, params, 0, param_count);
			return script_execute_array(f, arguments);
		}
	}
}

/// @desc Curries a function so arguments can be passed individually.
/// @param {script} ind the id of the script to apply currying to.
/// @param {int} arg_count The number of arguments to curry.
function curry(_count, _f) {
	return (new CurriedFunction(_count, _f)).call;
}

/// @desc Returns a new `+` operator section.
/// @param {value} rhs The right-hand-side value of the operation.
function op_plus(_rhs) { return method({ rhs : _rhs }, function(_x) { return _x + _rhs; }); }

/// @desc Returns a new `-` operator section.
/// @param {value} rhs The right-hand-side value of the operation.
function op_minus(_rhs) { return method({ rhs : _rhs }, function(_x) { return _x - _rhs; }); }

/// @desc Returns a new `*` operator section.
/// @param {value} rhs The right-hand-side value of the operation.
function op_product(_rhs) { return method({ rhs : _rhs }, function(_x) { return _x * _rhs; }); }

/// @desc Returns a new `/` operator section.
/// @param {value} rhs The right-hand-side value of the operation.
function op_divide(_rhs) { return method({ rhs : _rhs }, function(_x) { return _x / _rhs; }); }

/// @desc Returns a new operator section for remainders.
/// @param {value} rhs The right-hand-side value of the operation.
function op_modulo(_rhs) { return method({ rhs : _rhs }, function(_x) { return (_x % _rhs + _rhs) % _rhs; }); }

/// @desc Returns a new `div` operator section.
/// @param {value} rhs The right-hand-side value of the operation.
function op_quotient(_rhs) { return method({ rhs : _rhs }, function(_x) { return _x div _rhs; }); }

/// @desc Returns a new `%` operator section.
/// @param {value} rhs The right-hand-side value of the operation.
function op_remainder(_rhs) { return method({ rhs : _rhs }, function(_x) { return _x % _rhs; }); }

/// @desc Returns a new `==` operator section.
/// @param {value} rhs The right-hand-side value of the operation.
function op_equal(_rhs) { return method({ rhs : _rhs }, function(_x) { return _x == _rhs; }); }

/// @desc Returns a new `!=` operator section.
/// @param {value} rhs The right-hand-side value of the operation.
function op_nequal(_rhs) { return method({ rhs : _rhs }, function(_x) { return _x != _rhs; }); }

/// @desc Returns a new `>` operator section.
/// @param {value} rhs The right-hand-side value of the operation.
function op_greater(_rhs) { return method({ rhs : _rhs }, function(_x) { return _x > _rhs; }); }

/// @desc Returns a new `<` operator section.
/// @param {value} rhs The right-hand-side value of the operation.
function op_less(_rhs) { return method({ rhs : _rhs }, function(_x) { return _x < _rhs; }); }

/// @desc Returns a new `>=` operator section.
/// @param {value} rhs The right-hand-side value of the operation.
function op_greater_or_equal(_rhs) { return method({ rhs : _rhs }, function(_x) { return _x >= _rhs; }); }

/// @desc Returns a new `<=` operator section.
/// @param {value} rhs The right-hand-side value of the operation.
function op_less_or_equal(_rhs) { return method({ rhs : _rhs }, function(_x) { return _x <= _rhs; }); }

/// @desc Returns a new `&&` operator section.
/// @param {value} lhs The left-hand-side value of the operation.
function op_and(_lhs) { return method({ lhs : _lhs }, function(_x) { return lhs && _x; }); }

/// @desc Returns a new `||` operator section.
/// @param {value} lhs The left-hand-side value of the operation.
function op_or(_lhs) { return method({ lhs : _lhs }, function(_x) { return lhs || _x; }); }

/// @desc Returns a new `^^` operator section.
/// @param {value} lhs The left-hand-side value of the operation.
function op_xor(_lhs) { return method({ lhs : _lhs }, function(_x) { return lhs ^^ _x; }); }

/// @desc Returns a new `!` operator section.
/// @param {value} value Value of the operatoin.
function op_negate(_value) { return !_value; }

/// @desc Returns a new `&` operator section.
/// @param {value} lhs The left-hand-side value of the operation.
function op_and_bitwise(_lhs) { return method({ lhs : _lhs }, function(_x) { return lhs & _x; }); }

/// @desc Returns a new `|` operator section.
/// @param {value} lhs The left-hand-side value of the operation.
function op_or_bitwise(_lhs) { return method({ lhs : _lhs }, function(_x) { return lhs | _x; }); }

/// @desc Returns a new `^` operator section.
/// @param {value} lhs The left-hand-side value of the operation.
function op_xor_bitwise(_lhs) { return method({ lhs : _lhs }, function(_x) { return lhs ^ _x; }); }

/// @desc Returns a new `~` operator section.
/// @param {value} value Value of the operatoin.
function op_negate_bitwise(_value) { return ~_value; }