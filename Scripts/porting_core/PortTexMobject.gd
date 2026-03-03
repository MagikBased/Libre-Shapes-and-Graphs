class_name PortTexMobject
extends PortTextMobject

var _tex_source: String = ""
var tex_source: String:
	get:
		return _tex_source
	set(value):
		_tex_source = value
		text = _render_tex_to_display(_tex_source)


const GREEK_MAP := {
	"alpha": "alpha", "beta": "beta", "gamma": "gamma", "delta": "delta",
	"epsilon": "epsilon", "theta": "theta", "lambda": "lambda", "mu": "mu",
	"pi": "pi", "sigma": "sigma", "phi": "phi", "omega": "omega",
	"tau": "tau", "eta": "eta", "rho": "rho", "chi": "chi", "psi": "psi"
}

const SUPER_MAP := {
	"0": "0","1": "1","2": "2","3": "3","4": "4","5": "5","6": "6","7": "7","8": "8","9": "9",
	"+": "+","-": "-","=": "=","(": "(",")": ")","n": "n","i": "i"
}

const SUB_MAP := {
	"0": "0","1": "1","2": "2","3": "3","4": "4","5": "5","6": "6","7": "7","8": "8","9": "9",
	"+": "+","-": "-","=": "=","(": "(",")": ")","a": "a","e": "e","o": "o","x": "x"
}


func _render_tex_to_display(src: String) -> String:
	var s := src
	s = _strip_layout_wrappers(s)
	s = s.replace("\\\\", "\n")
	s = _replace_frac(s)
	s = _replace_sqrt(s)
	s = _replace_text(s)
	s = _replace_named_commands(s)
	s = _replace_greek(s)
	s = _replace_scripts(s, "^", SUPER_MAP)
	s = _replace_scripts(s, "_", SUB_MAP)
	s = s.replace("{", "").replace("}", "")
	return s


func get_match_tokens() -> PackedStringArray:
	var raw := _render_tex_to_display(tex_source)
	raw = raw.replace("\n", " ")
	var split := raw.split(" ", false)
	var tokens := PackedStringArray()
	for p in split:
		var token := p.strip_edges()
		if token.length() >= 2 and not tokens.has(token):
			tokens.append(token)
	return tokens


func _replace_frac(s: String) -> String:
	var out := s
	while true:
		var idx := out.find("\\frac{")
		if idx < 0:
			break
		var a_start := idx + 6
		var a_end := _find_matching_brace(out, a_start - 1)
		if a_end < 0 or a_end + 1 >= out.length() or out.substr(a_end + 1, 1) != "{":
			break
		var b_start := a_end + 2
		var b_end := _find_matching_brace(out, b_start - 1)
		if b_end < 0:
			break
		var a := out.substr(a_start, a_end - a_start)
		var b := out.substr(b_start, b_end - b_start)
		var repl := "(%s)/(%s)" % [a, b]
		out = out.substr(0, idx) + repl + out.substr(b_end + 1)
	return out


func _replace_sqrt(s: String) -> String:
	var out := s
	while true:
		var idx := out.find("\\sqrt{")
		if idx < 0:
			break
		var a_start := idx + 6
		var a_end := _find_matching_brace(out, a_start - 1)
		if a_end < 0:
			break
		var inner := out.substr(a_start, a_end - a_start)
		var repl := "sqrt(%s)" % inner
		out = out.substr(0, idx) + repl + out.substr(a_end + 1)
	return out


func _replace_greek(s: String) -> String:
	var out := s
	for key in GREEK_MAP.keys():
		out = out.replace("\\" + key, GREEK_MAP[key])
	return out


func _replace_named_commands(s: String) -> String:
	var out := s
	var replacements := {
		"\\cdot": "*",
		"\\times": "x",
		"\\pm": "+/-",
		"\\to": "->",
		"\\rightarrow": "->",
		"\\leftarrow": "<-",
		"\\geq": ">=",
		"\\leq": "<=",
		"\\neq": "!=",
		"\\approx": "~",
		"\\infty": "inf",
		"\\sum": "sum",
		"\\prod": "prod",
		"\\int": "int",
		"\\lim": "lim"
	}
	for k in replacements.keys():
		out = out.replace(k, str(replacements[k]))
	return out


func _replace_text(s: String) -> String:
	var out := s
	while true:
		var idx := out.find("\\text{")
		if idx < 0:
			break
		var start := idx + 6
		var end := _find_matching_brace(out, start - 1)
		if end < 0:
			break
		var body := out.substr(start, end - start)
		out = out.substr(0, idx) + body + out.substr(end + 1)
	return out


func _strip_layout_wrappers(s: String) -> String:
	var out := s
	out = out.replace("\\left", "")
	out = out.replace("\\right", "")
	out = out.replace("\\,", " ")
	out = out.replace("\\;", " ")
	out = out.replace("\\!", "")
	return out


func _replace_scripts(s: String, marker: String, map: Dictionary) -> String:
	var out := s
	var i := 0
	while i < out.length():
		if out.substr(i, 1) == marker:
			if i + 1 >= out.length():
				break
			if out.substr(i + 1, 1) == "{":
				var start := i + 2
				var end := _find_matching_brace(out, i + 1)
				if end < 0:
					break
				var body := out.substr(start, end - start)
				var mapped := _map_chars(body, map)
				out = out.substr(0, i) + mapped + out.substr(end + 1)
				i += mapped.length()
			else:
				var ch := out.substr(i + 1, 1)
				var mapped_single := _map_chars(ch, map)
				out = out.substr(0, i) + mapped_single + out.substr(i + 2)
				i += mapped_single.length()
		else:
			i += 1
	return out


func _map_chars(s: String, map: Dictionary) -> String:
	var out := ""
	for i in range(s.length()):
		var ch := s.substr(i, 1)
		out += map.get(ch, ch)
	return out


func _find_matching_brace(s: String, open_idx: int) -> int:
	var depth := 0
	for i in range(open_idx, s.length()):
		var ch := s.substr(i, 1)
		if ch == "{":
			depth += 1
		elif ch == "}":
			depth -= 1
			if depth == 0:
				return i
	return -1
