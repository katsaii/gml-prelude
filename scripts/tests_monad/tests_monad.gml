/* Tests monads
 * Kat @Katsaii
 */

var f;
var mf;
var mx;

// tests bind
f = function(_x) { return 2 * _x };
assert_eq(2, bind(1, f));
assert_eq(undefined, bind(undefined, f));
assert_eq(undefined, bind(12, undefined));

// tests apply
mf = [
	function(_x) { return ord(_x) },
	function(_x) { return _x + _x },
	function(_x) { return _x + "izard" }
];
mx = [
	"A", "B", "C"
];
show_message(apply(mf, mx));