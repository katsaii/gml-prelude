/* Assertion script
 * Kat @Katsaii
 */

if not (variable_global_exists("errors_exist")) {
	global.errors_exist = false;
}

function assert_eq(_expects, _got) {
	var callstack_pos = argument_count > 2 ? argument[2] : 1;
	var pass;
	if (is_array(_expects) && is_array(_got)) {
		pass = array_equals(_expects, _got);
	} else {
		pass = _expects == _got;
	}
	var msg = "got '" + string(_got) + "' (" + typeof(_got) + ")";
	if not (pass) {
		msg = "expected '" + string(_expects) + "' (" + typeof(_got) + ")" + msg;
		global.errors_exist = true;
	}
	var callstack = debug_get_callstack();
	show_debug_message((pass ? "PASS" : "FAIL") + " (" + callstack[callstack_pos] + "): " + msg);
}

function assert_neq(_expects, _got) {
	assert_eq(false, _expects == _got, 2);
}

function assert_true(_condition) {
	assert_eq(true, _condition, 2);
}

function assert_false(_condition) {
	assert_eq(false, _condition, 2);
}