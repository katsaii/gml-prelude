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
		var clone = array_create(count);
		for (var i = 0; i < count; i += 1) {
			clone[@ i] = _f(_mx[i]);
		}
		return clone;
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