/* Failure monad operations (See: `https://github.com/NuxiiGit/gml-prelude`)
 * Kat @Katsaii
 */

/// @desc Applies an impure function to an impure value.
/// @param {value} mv The value to apply the function to.
/// @param {value} mf The function to apply.
function apply(_mv, _mf) {
	return _mf == undefined || _mv == undefined ? undefined : _mf(_mv);
}