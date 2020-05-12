/* Tests monads
 * Kat @Katsaii
 */

var f;
var mf;

// tests bind
f = function(_x) { return 2 * _x };
assert_eq(2, bind(1, f));
assert_eq(undefined, bind(undefined, f));

// tests apply
mf = [
	function(_x) { return ord(_x) },
	function(_x) { return _x + _x },
	function(_x) { return _x + "izard" }
];
assert_eq([65, 66, 67, "AA", "BB", "CC", "Aizard", "Bizard", "Cizard"], apply(mf, ["A", "B", "C"]));

// tests lifted function
mf = function(_x) { return 4 * _x };
assert_eq(8, apply(mf, 2));
assert_eq(undefined, apply(mf, undefined));
assert_eq([-4, 8, 12], apply(mf, [-1, 2, 3]));
assert_eq([4, 4, 4, undefined, 4], apply(mf, [1, 1, 1, undefined, 1]));

// more tests lifted function
f = function(_a, _b) {
	return _a + _b;
}
mf = curry(f);
assert_eq(6, apply(apply(mf, 2), 4));
assert_eq(undefined, apply(apply(mf, 2), undefined));
assert_eq(undefined, apply(apply(mf, undefined), 2));
assert_eq(["AX", "AY", "AZ", "BX", "BY", "BZ", "CX", "CY", "CZ"], apply(apply(mf, ["A", "B", "C"]), ["X", "Y", "Z"]));

// tests join
assert_eq([1], join([[1]]));
assert_eq([undefined], join([undefined]));
assert_eq([undefined], join([[undefined]]));
assert_eq([2], join([[[2]]]));