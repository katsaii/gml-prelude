/* Assertion script
 */

function assert_eq(_expects, _got) {
	var msg = _expects == _got ? "PASS" : "FAIL";
	msg += ": expected '" + string(_expects) + "' got '" + string(_got) + "'";
	show_debug_message(msg);
}