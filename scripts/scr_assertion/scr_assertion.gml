/* Assertion script
 */

function assert_eq(_expects, _got) {
	var pass = _expects == _got;
	var msg = "expected '" + string(_expects) + "' got '" + string(_got) + "'";
	if not (pass) {
		var callstack = debug_get_callstack();
		msg += "\n  (callstack: " + callstack[1] + ")";
	}
	show_debug_message((pass ? "PASS" : "FAIL") + ": " + msg);
}