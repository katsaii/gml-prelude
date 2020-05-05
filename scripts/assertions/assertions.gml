/* Assertion script
 * Kat @Katsaii
 */

function assert_eq(_expects, _got) {
	var pass;
	if (is_array(_expects) && is_array(_got)) {
		pass = array_equals(_expects, _got);
	} else {
		pass = _expects == _got;
	}
	var msg = "got '" + string(_got) + "' (" + typeof(_got) + ")";
	if not (pass) {
		msg = "expected '" + string(_expects) + "' (" + typeof(_got) + ")" + msg;
	}
	var callstack = debug_get_callstack();
	show_debug_message((pass ? "PASS" : "FAIL") + " (" + callstack[1] + "): " + msg);
}

function assert_true(_condition) {
	assert_eq(true, _condition);
}

function assert_false(_condition) {
	assert_eq(false, _condition);
}