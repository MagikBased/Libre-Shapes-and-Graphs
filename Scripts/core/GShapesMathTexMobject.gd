class_name GShapesMathTexMobject
extends GShapesTexMobject

var _expressions: PackedStringArray = PackedStringArray()
var expressions: PackedStringArray:
	get:
		return _expressions
	set(value):
		_expressions = value
		_rebuild_tex_source()

var _separator: String = " = "
var separator: String:
	get:
		return _separator
	set(value):
		_separator = value
		_rebuild_tex_source()

var _multiline: bool = false
var multiline: bool:
	get:
		return _multiline
	set(value):
		_multiline = value
		_rebuild_tex_source()

var _multiline_align_separator: bool = false
var multiline_align_separator: bool:
	get:
		return _multiline_align_separator
	set(value):
		_multiline_align_separator = value
		_rebuild_tex_source()

var _multiline_separator_token: String = "="
var multiline_separator_token: String:
	get:
		return _multiline_separator_token
	set(value):
		_multiline_separator_token = value
		_rebuild_tex_source()

var _multiline_separator_tokens: PackedStringArray = PackedStringArray()
var multiline_separator_tokens: PackedStringArray:
	get:
		return _multiline_separator_tokens
	set(value):
		_multiline_separator_tokens = value
		_rebuild_tex_source()

var _multiline_separator_padding: int = 1
var multiline_separator_padding: int:
	get:
		return _multiline_separator_padding
	set(value):
		_multiline_separator_padding = maxi(0, value)
		_rebuild_tex_source()

var _align_mode: StringName = &"left"
var align_mode: StringName:
	get:
		return _align_mode
	set(value):
		_align_mode = value
		_apply_alignment()

var _isolate_tokens: PackedStringArray = PackedStringArray()
var isolate_tokens: PackedStringArray:
	get:
		return _isolate_tokens
	set(value):
		_isolate_tokens = value

var _token_groups: Array = []
var token_groups: Array:
	get:
		return _token_groups
	set(value):
		_token_groups = []
		for group in value:
			if group is PackedStringArray:
				_token_groups.append(group)
			elif group is Array:
				_token_groups.append(PackedStringArray(group))

var _token_splitters: PackedStringArray = PackedStringArray([
	" ", "=", "+", "-", "*", "/", "(", ")", "[", "]", "{", "}", ",", ":", ";"
])
var token_splitters: PackedStringArray:
	get:
		return _token_splitters
	set(value):
		_token_splitters = value

var _preserve_operator_tokens: bool = false
var preserve_operator_tokens: bool:
	get:
		return _preserve_operator_tokens
	set(value):
		_preserve_operator_tokens = value

var _expression_unsupported_commands: Array[PackedStringArray] = []


func _ready() -> void:
	super._ready()
	_apply_alignment()


func set_expressions(parts: Array[String]) -> GShapesMathTexMobject:
	expressions = PackedStringArray(parts)
	return self


func get_match_tokens() -> PackedStringArray:
	if not isolate_tokens.is_empty():
		return isolate_tokens
	if not token_groups.is_empty():
		var grouped := PackedStringArray()
		for g in token_groups:
			if g is PackedStringArray:
				for token in g:
					if token.length() >= 1 and not grouped.has(token):
						grouped.append(token)
		if not grouped.is_empty():
			return grouped
	if not expressions.is_empty():
		return _build_tokens_from_expressions()
	return super.get_match_tokens()


func _rebuild_tex_source() -> void:
	if expressions.is_empty():
		_expression_unsupported_commands = []
		tex_source = tex_source
		return
	_expression_unsupported_commands = []
	for expr in expressions:
		_expression_unsupported_commands.append(get_unsupported_commands_for_source(expr))
	var rendered_expressions: PackedStringArray = expressions
	if multiline and multiline_align_separator:
		rendered_expressions = _align_expressions_on_separator(expressions)
	var glue := "\\\\ " if multiline else separator
	var combined := ""
	for i in range(rendered_expressions.size()):
		if i > 0:
			combined += glue
		combined += rendered_expressions[i]
	tex_source = combined


func get_last_expression_unsupported_commands() -> Array[PackedStringArray]:
	return _expression_unsupported_commands


func _apply_alignment() -> void:
	if _label == null:
		return
	match String(align_mode).to_lower():
		"center":
			_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER as HorizontalAlignment
		"right":
			_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT as HorizontalAlignment
		_:
			_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT as HorizontalAlignment


func _build_tokens_from_expressions() -> PackedStringArray:
	var out := PackedStringArray()
	for e in expressions:
		var rendered := _render_tex_to_display(e)
		var tokens := _split_expression_tokens(rendered)
		for token in tokens:
			if token.length() >= 1 and not out.has(token):
				out.append(token)
	return out


func _split_expression_tokens(rendered_expression: String) -> PackedStringArray:
	var out := PackedStringArray()
	var current := ""
	for i in range(rendered_expression.length()):
		var ch := rendered_expression.substr(i, 1)
		var is_splitter := token_splitters.has(ch)
		if is_splitter:
			var token := current.strip_edges()
			if token.length() >= 1:
				out.append(token)
			current = ""
			if preserve_operator_tokens and ch.strip_edges().length() > 0:
				out.append(ch)
		else:
			current += ch
	var last := current.strip_edges()
	if last.length() >= 1:
		out.append(last)
	return out


func _align_expressions_on_separator(lines: PackedStringArray) -> PackedStringArray:
	var out: PackedStringArray = PackedStringArray()
	if lines.is_empty():
		return out
	var active_tokens: PackedStringArray = _resolve_active_separator_tokens()
	if active_tokens.is_empty():
		out.append_array(lines)
		return out

	var max_left_len: int = 0
	for line in lines:
		var split: Dictionary = _find_separator_split(line, active_tokens)
		if bool(split.get("found", false)):
			var left_part: String = str(split.get("left", ""))
			max_left_len = maxi(max_left_len, left_part.strip_edges().length())

	for line in lines:
		var split: Dictionary = _find_separator_split(line, active_tokens)
		if not bool(split.get("found", false)):
			out.append(line)
			continue
		var left: String = str(split.get("left", "")).strip_edges()
		var token: String = str(split.get("token", ""))
		var right: String = str(split.get("right", "")).strip_edges()
		var left_padded: String = _pad_right_spaces(left, max_left_len)
		var pad_spaces: String = " ".repeat(multiline_separator_padding)
		out.append("%s%s%s%s%s" % [left_padded, pad_spaces, token, pad_spaces, right])
	return out


func _resolve_active_separator_tokens() -> PackedStringArray:
	var out: PackedStringArray = PackedStringArray()
	for token in multiline_separator_tokens:
		var clean: String = token.strip_edges()
		if clean.length() > 0 and not out.has(clean):
			out.append(clean)
	var primary: String = multiline_separator_token.strip_edges()
	if primary.length() > 0 and not out.has(primary):
		out.insert(0, primary)
	return out


func _find_separator_split(line: String, tokens: PackedStringArray) -> Dictionary:
	var best_idx: int = -1
	var best_token: String = ""
	for token in tokens:
		var idx: int = line.find(token)
		if idx < 0:
			continue
		if best_idx < 0 or idx < best_idx:
			best_idx = idx
			best_token = token
	if best_idx < 0:
		return {"found": false}
	var left: String = line.substr(0, best_idx)
	var right: String = line.substr(best_idx + best_token.length())
	return {
		"found": true,
		"left": left,
		"token": best_token,
		"right": right
	}


func _pad_right_spaces(s: String, width: int) -> String:
	if s.length() >= width:
		return s
	return s + " ".repeat(width - s.length())



