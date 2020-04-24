/* Higher order functions
 * Kat @Katsaii
 */

/// @desc Converts a built-in function into a usable function pointer.
/// @param {function} name The name of the built-in function to obtain.
function func_ptr(_name) {
	return method({}, _name);
}

/// @desc The identity function. Returns the input value.
/// @param {value} value The value to return.
function identity(_a) {
	return _a;
}

/// @desc Ignores all input. Returns nothing.
function noop() {
	var _ = argument_count; // required to stop compiler errors when passing arguments
}

/// @desc Calls a function using an array as the parameter array.
/// @param {script} ind The id of the script to call.
/// @param {array} variable The id of the array to pass as a parameter array to this script.
function script_execute_array(_f, _a) {
	switch(array_length(_a)){
    case 0: return script_execute(_f);
    case 1: return script_execute(_f, _a[0]);
    case 2: return script_execute(_f, _a[0], _a[1]);
    case 3: return script_execute(_f, _a[0], _a[1], _a[2]);
    case 4: return script_execute(_f, _a[0], _a[1], _a[2], _a[3]);
    case 5: return script_execute(_f, _a[0], _a[1], _a[2], _a[3], _a[4]);
    case 6: return script_execute(_f, _a[0], _a[1], _a[2], _a[3], _a[4], _a[5]);
    case 7: return script_execute(_f, _a[0], _a[1], _a[2], _a[3], _a[4], _a[5], _a[6]);
    case 8: return script_execute(_f, _a[0], _a[1], _a[2], _a[3], _a[4], _a[5], _a[6], _a[7]);
    case 9: return script_execute(_f, _a[0], _a[1], _a[2], _a[3], _a[4], _a[5], _a[6], _a[7], _a[8]);
    case 10: return script_execute(_f, _a[0], _a[1], _a[2], _a[3], _a[4], _a[5], _a[6], _a[7], _a[8], _a[9]);
    case 11: return script_execute(_f, _a[0], _a[1], _a[2], _a[3], _a[4], _a[5], _a[6], _a[7], _a[8], _a[9], _a[10]);
    case 12: return script_execute(_f, _a[0], _a[1], _a[2], _a[3], _a[4], _a[5], _a[6], _a[7], _a[8], _a[9], _a[10], _a[11]);
    case 13: return script_execute(_f, _a[0], _a[1], _a[2], _a[3], _a[4], _a[5], _a[6], _a[7], _a[8], _a[9], _a[10], _a[11], _a[12]);
    case 14: return script_execute(_f, _a[0], _a[1], _a[2], _a[3], _a[4], _a[5], _a[6], _a[7], _a[8], _a[9], _a[10], _a[11], _a[12], _a[13]);
    case 15: return script_execute(_f, _a[0], _a[1], _a[2], _a[3], _a[4], _a[5], _a[6], _a[7], _a[8], _a[9], _a[10], _a[11], _a[12], _a[13], _a[14]);
    case 16: return script_execute(_f, _a[0], _a[1], _a[2], _a[3], _a[4], _a[5], _a[6], _a[7], _a[8], _a[9], _a[10], _a[11], _a[12], _a[13], _a[14], _a[15]);
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
/// @param {int} arg_count The number of arguments to curry.
/// @param {script} ind the id of the script to apply currying to.
function curry(_count, _f) {
	return (new CurriedFunction(_count, _f)).call;
}

/// @desc Curries a function which takes two arguments.
/// @param {script} ind The id of the script to apply currying to.
function curry_pair(_f) {
	return method({
		f : _f
	}, function(_a) {
		return method({
			f : self.f,
			a : _a
		}, function(_b) {
			return f(a, _b);
		});
	});
}

/// @desc Curries a function which takes three arguments.
/// @param {script} ind The id of the script to apply currying to.
function curry_trip(_f) {
	return method({
		f : _f
	}, function(_a) {
		return method({
			f : self.f,
			a : _a
		}, function(_b) {
			return method({
				f : self.f,
				a : self.a,
				b : _b
			}, function(_c) {
				return f(a, b, _c);
			});
		});
	});
}

/// @desc Curries a function which takes four arguments.
/// @param {script} ind The id of the script to apply currying to.
function curry_quad(_f) {
	return method({
		f : _f
	}, function(_a) {
		return method({
			f : self.f,
			a : _a
		}, function(_b) {
			return method({
				f : self.f,
				a : self.a,
				b : _b
			}, function(_c) {
				return method({
					f : self.f,
					a : self.a,
					b : self.b,
					c : _c
				}, function(_d) {
					return f(a, b, c, _d);
				});
			});
		});
	});
}