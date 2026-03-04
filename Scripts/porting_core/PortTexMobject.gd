class_name PortTexMobject
extends PortTextMobject

var _tex_source: String = ""
var tex_source: String:
	get:
		return _tex_source
	set(value):
		_tex_source = value
		text = _render_tex_to_display(_tex_source)

var warn_on_unsupported_commands: bool = false
var unsupported_command_prefix: String = "?"
var _last_unsupported_commands: PackedStringArray = PackedStringArray()
var last_unsupported_commands: PackedStringArray:
	get:
		return _last_unsupported_commands


const GREEK_MAP := {
	"alpha": "alpha", "beta": "beta", "gamma": "gamma", "delta": "delta",
	"epsilon": "epsilon", "theta": "theta", "lambda": "lambda", "mu": "mu",
	"pi": "pi", "sigma": "sigma", "phi": "phi", "omega": "omega",
	"tau": "tau", "eta": "eta", "rho": "rho", "chi": "chi", "psi": "psi",
	"Gamma": "Gamma", "Delta": "Delta", "Theta": "Theta", "Lambda": "Lambda",
	"Pi": "Pi", "Sigma": "Sigma", "Phi": "Phi", "Omega": "Omega"
}

const SUPER_MAP := {
	"0": "0","1": "1","2": "2","3": "3","4": "4","5": "5","6": "6","7": "7","8": "8","9": "9",
	"+": "+","-": "-","=": "=","(": "(",")": ")","n": "n","i": "i"
}

const SUB_MAP := {
	"0": "0","1": "1","2": "2","3": "3","4": "4","5": "5","6": "6","7": "7","8": "8","9": "9",
	"+": "+","-": "-","=": "=","(": "(",")": ")","a": "a","e": "e","o": "o","x": "x"
}

const STYLE_PASSTHROUGH_COMMANDS := [
	"mathrm", "mathbf", "mathit", "mathsf", "mathtt", "mathbb", "mathcal", "mathfrak",
	"operatorname", "textbf", "textit", "textrm"
]

const DECORATION_COMMANDS := [
	"overline", "underline", "vec", "hat", "bar", "dot", "ddot", "tilde",
	"overrightarrow", "overleftarrow", "overbrace", "underbrace", "boxed", "cancel"
]

const KNOWN_PASSTHROUGH_COMMANDS := [
	"displaystyle", "textstyle", "scriptstyle", "scriptscriptstyle",
	"phantom", "hphantom", "vphantom", "smash", "mathop", "limits", "nolimits"
]

const SIMPLE_COMMAND_REPLACEMENTS := {
	"\\cdot": "*",
	"\\times": "x",
	"\\pm": "+/-",
	"\\mp": "-/+",
	"\\to": "->",
	"\\rightarrow": "->",
	"\\Rightarrow": "=>",
	"\\implies": "=>",
	"\\leftarrow": "<-",
	"\\Leftarrow": "<=",
	"\\leftrightarrow": "<->",
	"\\Leftrightarrow": "<=>",
	"\\iff": "<=>",
	"\\mapsto": "|->",
	"\\geq": ">=",
	"\\ge": ">=",
	"\\leq": "<=",
	"\\le": "<=",
	"\\neq": "!=",
	"\\doteq": ":=",
	"\\approx": "~",
	"\\sim": "~",
	"\\propto": "prop",
	"\\infty": "inf",
	"\\sum": "sum",
	"\\prod": "prod",
	"\\int": "int",
	"\\iint": "iint",
	"\\iiint": "iiint",
	"\\oint": "oint",
	"\\lim": "lim",
	"\\sin": "sin",
	"\\cos": "cos",
	"\\tan": "tan",
	"\\cot": "cot",
	"\\sec": "sec",
	"\\csc": "csc",
	"\\sinh": "sinh",
	"\\cosh": "cosh",
	"\\tanh": "tanh",
	"\\log": "log",
	"\\ln": "ln",
	"\\exp": "exp",
	"\\max": "max",
	"\\min": "min",
	"\\sup": "sup",
	"\\inf": "inf",
	"\\arg": "arg",
	"\\deg": "deg",
	"\\det": "det",
	"\\dim": "dim",
	"\\Pr": "Pr",
	"\\Re": "Re",
	"\\Im": "Im",
	"\\forall": "forall",
	"\\exists": "exists",
	"\\nexists": "!exists",
	"\\in": "in",
	"\\notin": "!in",
	"\\subset": "subset",
	"\\subseteq": "subseteq",
	"\\supset": "supset",
	"\\supseteq": "supseteq",
	"\\cup": "cup",
	"\\cap": "cap",
	"\\land": "and",
	"\\lor": "or",
	"\\neg": "not",
	"\\partial": "d",
	"\\nabla": "nabla",
	"\\cdots": "...",
	"\\ldots": "...",
	"\\dots": "...",
	"\\quad": " ",
	"\\qquad": " ",
	"\\!": "",
	"\\,": " ",
	"\\;": " ",
	"\\:": " "
}


func _render_tex_to_display(src: String) -> String:
	return _render_tex_fragment(src, true)


func _render_tex_fragment(src: String, track_unsupported: bool) -> String:
	var s := src
	s = _normalize_alias_commands(s)
	s = _normalize_delimiter_commands(s)
	if track_unsupported:
		_last_unsupported_commands = _collect_unknown_commands(s)
		if warn_on_unsupported_commands and not _last_unsupported_commands.is_empty():
			push_warning("PortTexMobject unsupported TeX commands: %s" % [", ".join(_last_unsupported_commands)])
	s = _strip_layout_wrappers(s)
	s = s.replace("\\\\", "\n")
	s = _replace_begin_end_environments(s)
	s = _replace_frac(s)
	s = _replace_binom(s)
	s = _replace_sqrt(s)
	s = _replace_overset_underset(s)
	s = _replace_text(s)
	s = _replace_style_commands(s)
	s = _replace_decoration_commands(s)
	s = _replace_named_commands(s)
	s = _replace_greek(s)
	s = _replace_scripts(s, "^", SUPER_MAP)
	s = _replace_scripts(s, "_", SUB_MAP)
	s = _replace_unknown_commands_for_fallback(s)
	s = s.replace("{", "").replace("}", "")
	return s


func get_match_tokens() -> PackedStringArray:
	var raw := _render_tex_to_display(tex_source)
	raw = raw.replace("\n", " ")
	var split := raw.split(" ", false)
	var tokens: PackedStringArray = PackedStringArray()
	for p in split:
		var token := p.strip_edges()
		if _is_token_match_candidate(token) and not tokens.has(token):
			tokens.append(token)
	return tokens


func get_last_unsupported_commands() -> PackedStringArray:
	return _last_unsupported_commands


func get_unsupported_commands_for_source(src: String) -> PackedStringArray:
	var s: String = _normalize_alias_commands(src)
	s = _normalize_delimiter_commands(s)
	return _collect_unknown_commands(s)


func has_unsupported_commands() -> bool:
	return not _last_unsupported_commands.is_empty()


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
		var idx := out.find("\\sqrt")
		if idx < 0:
			break
		var body_open: int = -1
		var index_text: String = ""
		var next_idx: int = idx + 5
		if next_idx < out.length() and out.substr(next_idx, 1) == "[":
			var index_end: int = _find_matching_square_bracket(out, next_idx)
			if index_end < 0:
				break
			index_text = out.substr(next_idx + 1, index_end - (next_idx + 1))
			body_open = index_end + 1
		else:
			body_open = idx + 5
		if body_open >= out.length() or out.substr(body_open, 1) != "{":
			break
		var a_start := body_open + 1
		var a_end := _find_matching_brace(out, body_open)
		if a_end < 0:
			break
		var inner := out.substr(a_start, a_end - a_start)
		var repl := "sqrt(%s)" % inner
		if index_text.length() > 0:
			repl = "root_%s(%s)" % [index_text, inner]
		out = out.substr(0, idx) + repl + out.substr(a_end + 1)
	return out


func _replace_binom(s: String) -> String:
	var out := s
	while true:
		var idx: int = out.find("\\binom{")
		if idx < 0:
			break
		var a_start: int = idx + 7
		var a_end: int = _find_matching_brace(out, a_start - 1)
		if a_end < 0 or a_end + 1 >= out.length() or out.substr(a_end + 1, 1) != "{":
			break
		var b_start: int = a_end + 2
		var b_end: int = _find_matching_brace(out, b_start - 1)
		if b_end < 0:
			break
		var top: String = out.substr(a_start, a_end - a_start)
		var bottom: String = out.substr(b_start, b_end - b_start)
		var repl: String = "C(%s,%s)" % [top, bottom]
		out = out.substr(0, idx) + repl + out.substr(b_end + 1)
	return out


func _replace_overset_underset(s: String) -> String:
	var out: String = s
	out = _replace_two_arg_command(out, "overset", "(%s)^(%s)")
	out = _replace_two_arg_command(out, "underset", "(%s)_(%s)")
	return out


func _replace_two_arg_command(s: String, command_name: String, format_pattern: String) -> String:
	var out: String = s
	var needle: String = "\\" + command_name + "{"
	while true:
		var idx: int = out.find(needle)
		if idx < 0:
			break
		var a_start: int = idx + needle.length()
		var a_end: int = _find_matching_brace(out, a_start - 1)
		if a_end < 0 or a_end + 1 >= out.length() or out.substr(a_end + 1, 1) != "{":
			break
		var b_start: int = a_end + 2
		var b_end: int = _find_matching_brace(out, b_start - 1)
		if b_end < 0:
			break
		var a: String = out.substr(a_start, a_end - a_start)
		var b: String = out.substr(b_start, b_end - b_start)
		var repl: String = format_pattern % [a, b]
		out = out.substr(0, idx) + repl + out.substr(b_end + 1)
	return out


func _replace_greek(s: String) -> String:
	var out := s
	for key in GREEK_MAP.keys():
		out = out.replace("\\" + key, GREEK_MAP[key])
	return out


func _replace_named_commands(s: String) -> String:
	var out := s
	for k in SIMPLE_COMMAND_REPLACEMENTS.keys():
		out = out.replace(k, str(SIMPLE_COMMAND_REPLACEMENTS[k]))
	return out


func _replace_text(s: String) -> String:
	return _replace_command_with_braced_body(s, "text")


func _replace_style_commands(s: String) -> String:
	var out := s
	for cmd in STYLE_PASSTHROUGH_COMMANDS:
		out = _replace_command_with_braced_body(out, cmd)
	return out


func _replace_decoration_commands(s: String) -> String:
	var out := s
	for cmd in DECORATION_COMMANDS:
		out = _replace_command_with_braced_body(out, cmd)
	return out


func _replace_command_with_braced_body(s: String, command_name: String) -> String:
	var out := s
	var needle: String = "\\" + command_name + "{"
	while true:
		var idx: int = out.find(needle)
		if idx < 0:
			break
		var start: int = idx + needle.length()
		var end: int = _find_matching_brace(out, start - 1)
		if end < 0:
			break
		var body: String = out.substr(start, end - start)
		out = out.substr(0, idx) + body + out.substr(end + 1)
	return out


func _strip_layout_wrappers(s: String) -> String:
	var out := s
	out = out.replace("\\left.", "")
	out = out.replace("\\right.", "")
	out = out.replace("\\left", "")
	out = out.replace("\\right", "")
	out = out.replace("\\,", " ")
	out = out.replace("\\;", " ")
	out = out.replace("\\!", "")
	return out


func _normalize_alias_commands(s: String) -> String:
	var out := s
	var mapped := {
		"\\dfrac": "\\frac",
		"\\tfrac": "\\frac",
		"\\cfrac": "\\frac",
		"\\dbinom": "\\binom",
		"\\tbinom": "\\binom",
		"\\operatorname*": "\\operatorname",
		"\\Bigl": "",
		"\\Bigr": "",
		"\\bigl": "",
		"\\bigr": "",
		"\\Biggl": "",
		"\\Biggr": "",
		"\\biggl": "",
		"\\biggr": "",
		"\\Big": "",
		"\\big": "",
		"\\Bigg": "",
		"\\bigg": "",
		"\\Bigm": "",
		"\\bigm": "",
		"\\middle": ""
	}
	for k in mapped.keys():
		out = out.replace(k, str(mapped[k]))
	return out


func _normalize_delimiter_commands(s: String) -> String:
	var out := s
	var mapped := {
		"\\{": "{",
		"\\}": "}",
		"\\lbrace": "{",
		"\\rbrace": "}",
		"\\lfloor": "[",
		"\\rfloor": "]",
		"\\lceil": "[",
		"\\rceil": "]",
		"\\lvert": "|",
		"\\rvert": "|",
		"\\lVert": "||",
		"\\rVert": "||",
		"\\vert": "|",
		"\\Vert": "||",
		"\\langle": "<",
		"\\rangle": ">"
	}
	for k in mapped.keys():
		out = out.replace(k, str(mapped[k]))
	return out


func _replace_begin_end_environments(s: String) -> String:
	var out := s
	while true:
		var begin_idx: int = out.find("\\begin{")
		if begin_idx < 0:
			break
		var env_name_start: int = begin_idx + 7
		var env_name_end: int = _find_matching_brace(out, env_name_start - 1)
		if env_name_end < 0:
			break
		var env_name: String = out.substr(env_name_start, env_name_end - env_name_start)
		var body_start: int = env_name_end + 1
		var end_idx: int = _find_matching_environment_end(out, env_name, body_start)
		if end_idx < 0:
			break
		var end_token: String = "\\end{%s}" % env_name
		var body: String = out.substr(body_start, end_idx - body_start)
		var repl: String = _render_environment_body(env_name, body)
		out = out.substr(0, begin_idx) + repl + out.substr(end_idx + end_token.length())
	return out


func _find_matching_environment_end(src: String, env_name: String, search_start: int) -> int:
	var begin_token: String = "\\begin{%s}" % env_name
	var end_token: String = "\\end{%s}" % env_name
	var depth: int = 1
	var cursor: int = search_start
	while cursor < src.length():
		var next_begin: int = src.find(begin_token, cursor)
		var next_end: int = src.find(end_token, cursor)
		if next_end < 0:
			return -1
		if next_begin >= 0 and next_begin < next_end:
			depth += 1
			cursor = next_begin + begin_token.length()
			continue
		depth -= 1
		if depth == 0:
			return next_end
		cursor = next_end + end_token.length()
	return -1


func _render_environment_body(env_name: String, body: String) -> String:
	var n: String = env_name.strip_edges().to_lower()
	var out: String = body
	out = out.replace("\\hline", "")
	out = out.replace("\\,", " ")
	out = out.replace("\\;", " ")
	var multiline_out: String = out.replace("\\\\", "\n")
	var aligned_out: String = multiline_out.replace("&", "  ")

	if n == "cases":
		var lines: PackedStringArray = aligned_out.split("\n", false)
		var merged: PackedStringArray = PackedStringArray()
		for line in lines:
			var clean: String = line.strip_edges()
			if clean.length() > 0:
				merged.append(clean)
		return "{ " + " ; ".join(merged) + " }"

	if n == "align" or n == "aligned" or n == "align*" or n == "gather" or n == "gather*" or n == "array" or n == "split" or n == "multline" or n == "multline*" or n == "equation" or n == "equation*":
		var align_lines: PackedStringArray = aligned_out.split("\n", false)
		var clean_lines: PackedStringArray = PackedStringArray()
		for line in align_lines:
			var clean: String = line.strip_edges()
			if clean.length() > 0:
				clean_lines.append(clean)
		return "\n".join(clean_lines)

	# Matrix-like formatting (`matrix`, `pmatrix`, `bmatrix`, `Bmatrix`, `vmatrix`, `Vmatrix`, `smallmatrix`)
	if n == "matrix" or n == "pmatrix" or n == "bmatrix" or n == "bmatrix*" or n == "vmatrix" or n == "smallmatrix":
		var rows: PackedStringArray = multiline_out.split("\n", false)
		var row_parts: PackedStringArray = PackedStringArray()
		for row in rows:
			var raw_row: String = row.strip_edges()
			if raw_row.length() == 0:
				continue
			var cols: PackedStringArray = raw_row.split("&", false)
			var clean_cols: PackedStringArray = PackedStringArray()
			for col in cols:
				var clean_col: String = col.strip_edges()
				if clean_col.length() > 0:
					clean_cols.append(clean_col)
			if clean_cols.is_empty():
				continue
			row_parts.append("[" + ", ".join(clean_cols) + "]")
		if row_parts.is_empty():
			return multiline_out
		return "[" + "; ".join(row_parts) + "]"

	return aligned_out


func _replace_unknown_commands_for_fallback(s: String) -> String:
	var out := s
	var i: int = 0
	while i < out.length():
		if out.substr(i, 1) != "\\":
			i += 1
			continue
		var cmd_start: int = i + 1
		var cmd_end: int = cmd_start
		while cmd_end < out.length():
			var ch: String = out.substr(cmd_end, 1)
			if not _is_ascii_letter(ch):
				break
			cmd_end += 1
		if cmd_end == cmd_start:
			i += 1
			continue
		var command_name: String = out.substr(cmd_start, cmd_end - cmd_start)
		if _is_known_command(command_name):
			i = cmd_end
			continue
		var fallback: String = unsupported_command_prefix + command_name
		out = out.substr(0, i) + fallback + out.substr(cmd_end)
		i += fallback.length()
	return out


func _collect_unknown_commands(src: String) -> PackedStringArray:
	var out: PackedStringArray = PackedStringArray()
	var i: int = 0
	while i < src.length():
		if src.substr(i, 1) != "\\":
			i += 1
			continue
		var cmd_start: int = i + 1
		var cmd_end: int = cmd_start
		while cmd_end < src.length():
			var ch: String = src.substr(cmd_end, 1)
			if not _is_ascii_letter(ch):
				break
			cmd_end += 1
		if cmd_end == cmd_start:
			i += 1
			continue
		var command_name: String = src.substr(cmd_start, cmd_end - cmd_start)
		if not _is_known_command(command_name) and not out.has(command_name):
			out.append(command_name)
		i = cmd_end
	return out


func _is_known_command(command_name: String) -> bool:
	if GREEK_MAP.has(command_name):
		return true
	if command_name == "frac" or command_name == "sqrt" or command_name == "text":
		return true
	if command_name == "overset" or command_name == "underset":
		return true
	if STYLE_PASSTHROUGH_COMMANDS.has(command_name):
		return true
	if DECORATION_COMMANDS.has(command_name):
		return true
	if KNOWN_PASSTHROUGH_COMMANDS.has(command_name):
		return true
	if SIMPLE_COMMAND_REPLACEMENTS.has("\\" + command_name):
		return true
	if command_name == "left" or command_name == "right":
		return true
	if command_name == "begin" or command_name == "end":
		return true
	return false


func _is_ascii_letter(ch: String) -> bool:
	return (ch >= "a" and ch <= "z") or (ch >= "A" and ch <= "Z")


func _replace_scripts(s: String, marker: String, map: Dictionary) -> String:
	var out := s
	var i: int = 0
	while i < out.length():
		if out.substr(i, 1) == marker:
			if i + 1 >= out.length():
				break
			if out.substr(i + 1, 1) == "{":
				var start: int = i + 2
				var end: int = _find_matching_brace(out, i + 1)
				if end < 0:
					break
				var body: String = out.substr(start, end - start)
				var mapped: String = _render_script_body(marker, body, map)
				out = out.substr(0, i) + mapped + out.substr(end + 1)
				i += mapped.length()
			else:
				var ch: String = out.substr(i + 1, 1)
				var mapped_single: String = _render_script_body(marker, ch, map)
				out = out.substr(0, i) + mapped_single + out.substr(i + 2)
				i += mapped_single.length()
		else:
			i += 1
	return out


func _render_script_body(marker: String, body: String, map: Dictionary) -> String:
	var clean: String = body.strip_edges()
	if clean.length() <= 1 and not clean.contains("\\"):
		return _map_chars(clean, map)
	if not clean.contains("\\") and not clean.contains("{") and not clean.contains("}"):
		return _map_chars(clean, map)
	var rendered: String = _render_tex_fragment(clean, false).replace("\n", " ")
	return "%s(%s)" % [marker, rendered]


func _map_chars(s: String, map: Dictionary) -> String:
	var out := ""
	for i in range(s.length()):
		var ch := s.substr(i, 1)
		out += map.get(ch, ch)
	return out


func _is_token_match_candidate(token: String) -> bool:
	var clean: String = token.strip_edges()
	if clean.length() >= 2:
		return true
	if clean.length() != 1:
		return false
	return _is_ascii_letter(clean) or (clean >= "0" and clean <= "9")


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


func _find_matching_square_bracket(s: String, open_idx: int) -> int:
	var depth: int = 0
	for i in range(open_idx, s.length()):
		var ch: String = s.substr(i, 1)
		if ch == "[":
			depth += 1
		elif ch == "]":
			depth -= 1
			if depth == 0:
				return i
	return -1
