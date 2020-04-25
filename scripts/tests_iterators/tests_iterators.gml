/* Tests iterator behaviour
 * Kat @Katsaii
 */

var array_iter = iterator([1, 2, 3]);

assert_eq(1, next(array_iter));

assert_eq([2, 3], iterate(array_iter));

assert_eq([undefined, undefined, undefined], take(3, array_iter));

var struct = {
	pos : 0,
	__next__ : function() {
		pos += 1;
		return pos;
	}
};

var struct_iter = iterator(struct);

assert_eq([1, 2, 3, 4], take(4, struct_iter));

drop(4, struct_iter); // [5, 6, 7, 8]

assert_eq([9], take(1, struct_iter));

assert_eq([], take(0, struct_iter));