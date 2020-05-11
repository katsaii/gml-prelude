/* Tests monads
 * Kat @Katsaii
 */

var mf;

// tests bind
mf = function(_x) { return 2 * _x };
assert_eq(2, bind(1, mf));
assert_eq(undefined, bind(undefined, mf));
assert_eq(undefined, bind(12, undefined));

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

// tests join
assert_eq([1], join([[1]]));
assert_eq([undefined], join([undefined]));
assert_eq([undefined], join([[undefined]]));
assert_eq([2], join([[[2]]]));