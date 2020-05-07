/* Higher order functions (See: `https://github.com/NuxiiGit/functionalism`)
 * Kat @Katsaii
 */

/// @desc Converts a built-in function into a usable function pointer.
/// @param {function} name The name of the built-in function to obtain.
function func_ptr(_name) {
	return method(undefined, _name);
}

/// @desc The identity function. Returns the input value.
/// @param {value} value The value to return.
function identity(_x) {
	return _x;
}

/// @desc The no-op function. Takes nothing and returns nothing.
function noop() {
	return undefined;
}

/// @desc Composes two functions together.
/// @param {script} f The function to feed the result of `g(x)`.
/// @param {script} g The function to feed `x`.
function compose(_f, _g) {
	return method({
		f : _f,
		g : _g
	}, function(_x) {
		return f(g(_x));
	});
}

/// @desc Calls a function using an array as the parameter array.
/// @param {script} ind The id of the script to call.
/// @param {array} variable The id of the array to pass as a parameter array to this script.
function script_execute_array(_f, _a) {
	if (is_method(_f)) {
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
		}
	} else {
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
		}
	}
	throw "argument count of " + string(array_length(_a)) + " is not supported";
}

/// @desc Generates a new function with a number of arguments partially applied.
/// @param {script} ind the id of the script or method to apply currying to.
/// @param {value} [args] The arguments to partially apply to the function.
function curry(_f) {
	var count = argument_count - 1;
	var args = array_create(count);
	for (var i = count - 1; i >= 0; i -= 1) {
		args[@ i] = argument[i + 1];
	}
	return method({
		f : _f,
		len : count,
		closure : args
	}, function() {
		var args = array_create(len + argument_count);
		array_copy(args, 0, closure, 0, len);
		for (var i = argument_count - 1; i >= 0; i -= 1) {
			args[@ len + i] = argument[i];
		}
		return script_execute_array(f, args);
	});
}