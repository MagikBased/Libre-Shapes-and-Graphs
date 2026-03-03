class_name PortMathTexMobject
extends PortTexMobject

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


func _ready() -> void:
	super._ready()
	_apply_alignment()


func set_expressions(parts: Array[String]) -> PortMathTexMobject:
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
		tex_source = tex_source
		return
	var glue := "\\\\ " if multiline else separator
	var combined := ""
	for i in range(expressions.size()):
		if i > 0:
			combined += glue
		combined += expressions[i]
	tex_source = combined


func _apply_alignment() -> void:
	if _label == null:
		return
	match String(align_mode).to_lower():
		"center":
			_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		"right":
			_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		_:
			_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT


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
