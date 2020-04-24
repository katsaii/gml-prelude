/* Higher order functions
 * Kat @Katsaii
 */

/// @desc Converts a built-in function into a usable function pointer.
/// @param {function} name The name of the built-in function to obtain.
function func_ptr(_name) {
	return method({}, _name);
}

/// @desc Calls a function using an array as the parameter array.
/// @param {script} ind The id of the script to call.
/// @param {array} variable The id of the array to pass as a parameter array to this script.
function script_execute_array(_f, _array) {
	var f = _f;
	var a = _array;
	switch(array_length(a)){
    case 0: return script_execute(f);
    case 1: return script_execute(f, a[|0]);
    case 2: return script_execute(f, a[|0], a[|1]);
    case 3: return script_execute(f, a[|0], a[|1], a[|2]);
    case 4: return script_execute(f, a[|0], a[|1], a[|2], a[|3]);
    case 5: return script_execute(f, a[|0], a[|1], a[|2], a[|3], a[|4]);
    case 6: return script_execute(f, a[|0], a[|1], a[|2], a[|3], a[|4], a[|5]);
    case 7: return script_execute(f, a[|0], a[|1], a[|2], a[|3], a[|4], a[|5], a[|6]);
    case 8: return script_execute(f, a[|0], a[|1], a[|2], a[|3], a[|4], a[|5], a[|6], a[|7]);
    case 9: return script_execute(f, a[|0], a[|1], a[|2], a[|3], a[|4], a[|5], a[|6], a[|7], a[|8]);
    case 10: return script_execute(f, a[|0], a[|1], a[|2], a[|3], a[|4], a[|5], a[|6], a[|7], a[|8], a[|9]);
    case 11: return script_execute(f, a[|0], a[|1], a[|2], a[|3], a[|4], a[|5], a[|6], a[|7], a[|8], a[|9], a[|10]);
    case 12: return script_execute(f, a[|0], a[|1], a[|2], a[|3], a[|4], a[|5], a[|6], a[|7], a[|8], a[|9], a[|10], a[|11]);
    case 13: return script_execute(f, a[|0], a[|1], a[|2], a[|3], a[|4], a[|5], a[|6], a[|7], a[|8], a[|9], a[|10], a[|11], a[|12]);
    case 14: return script_execute(f, a[|0], a[|1], a[|2], a[|3], a[|4], a[|5], a[|6], a[|7], a[|8], a[|9], a[|10], a[|11], a[|12], a[|13]);
    case 15: return script_execute(f, a[|0], a[|1], a[|2], a[|3], a[|4], a[|5], a[|6], a[|7], a[|8], a[|9], a[|10], a[|11], a[|12], a[|13], a[|14]);
    case 16: return script_execute(f, a[|0], a[|1], a[|2], a[|3], a[|4], a[|5], a[|6], a[|7], a[|8], a[|9], a[|10], a[|11], a[|12], a[|13], a[|14], a[|15]);
    default: show_error("argument count of " + string(a) + " is not supported", false);
	}
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