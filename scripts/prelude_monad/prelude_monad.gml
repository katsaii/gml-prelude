/* Monad library
 * -------------
 * Kat @Katsaii
 * `https://github.com/NuxiiGit/gml-prelude`
 */

/// @desc Binds an nullable impure value to a nullable function.
/// @param {value_or_array} ma The impure value to feed into `f`.
/// @param {script} f The function to apply to elements of `ma`.
function bind(_ma, _f) {
	if (_ma == undefined || _f == undefined) {
		return undefined;
	}
	if (is_array(_ma)) {
		var count = array_length(_ma);
		var clone = array_create(count);
		for (var i = 0; i < count; i += 1) {
			clone[@ i] = _f(_ma[i]);
		}
		return clone;
	} else {
		return _f(_ma);
	}
}