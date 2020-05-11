/* Monad library
 * -------------
 * Kat @Katsaii
 * `https://github.com/NuxiiGit/gml-prelude`
 */

/// @desc Binds an nullable impure value to a nullable function.
/// @param {value_or_array} mx The impure value to feed into `f`.
/// @param {script} f The function to apply to elements of `mx`.
function bind(_mx, _f) {
	if (_mx == undefined || _f == undefined) {
		return undefined;
	}
	if (is_array(_mx)) {
		var count = array_length(_mx);
		var my = array_create(count);
		var pos = 0;
		for (var i = 0; i < count; i += 1) {
			var yy = bind(_mx[i], _f);
			if (yy == undefined) {
				return undefined;
			}
			if (is_array(yy)) {
				var count2 = array_length(yy);
				var start = pos;
				for (; pos - start < count2; pos += 1) {
					my[@ pos] = yy[pos - start];
				}
			} else {
				my[@ pos] = yy;
				pos += 1;
			}
		}
		return my;
	} else {
		return _f(_mx);
	}
}

/// @desc Applies a nullable impure function to a nullable impure value.
/// @param {value_or_array} mf The impure value function.
/// @param {value_or_array} mx The impure value.
function apply(_mf, _mx) {
	return bind(_mf, method({
		mx : _mx
	}, function(_f) {
		return bind(mx, _f);
	}));
}