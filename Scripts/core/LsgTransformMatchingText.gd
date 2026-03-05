class_name LsgTransformMatchingText
extends LsgAnimation

const TOKEN_SPLITTERS := [
	" ", "\n", "\t", "=", "+", "-", "*", "/", "(", ")", "[", "]", "{", "}", ",", ":", ";"
]

var source: LsgTextMobject
var destination: LsgTextMobject
var path_arc: float = 0.0
var matched_keys: PackedStringArray = PackedStringArray()
var key_map: Dictionary = {}

var _source_start_modulate: Color = Color.WHITE
var _destination_start_modulate: Color = Color.WHITE
var _source_position: Vector2 = Vector2.ZERO
var _destination_position: Vector2 = Vector2.ZERO
var _source_anchor_local: Vector2 = Vector2.ZERO
var _destination_anchor_local: Vector2 = Vector2.ZERO


func _init(
	p_source: LsgTextMobject,
	p_destination: LsgTextMobject,
	p_run_time: float = 1.0,
	p_rate_func_name: StringName = &"smooth",
	p_path_arc: float = 0.0,
	p_matched_keys: PackedStringArray = PackedStringArray(),
	p_key_map: Dictionary = {}
) -> void:
	source = p_source
	destination = p_destination
	path_arc = p_path_arc
	matched_keys = p_matched_keys
	key_map = p_key_map
	super(null, p_run_time, p_rate_func_name)


func on_begin() -> void:
	if source == null or destination == null:
		return
	_source_start_modulate = source.modulate
	_destination_start_modulate = destination.modulate
	_source_position = source.position
	_destination_position = destination.position
	_source_anchor_local = _estimate_anchor_offset(source, _pick_source_anchor(source.text))
	_destination_anchor_local = _estimate_anchor_offset(destination, _pick_destination_anchor(destination.text))

	# Align destination anchor to source anchor at start.
	if _has_match_hint():
		destination.position = _source_position + _source_anchor_local - _destination_anchor_local

	var d := destination.modulate
	d.a = 0.0
	destination.modulate = d


func interpolate(alpha: float) -> void:
	if source == null or destination == null:
		return
	var t: float = clampf(alpha, 0.0, 1.0)

	var s := _source_start_modulate
	s.a = _source_start_modulate.a * (1.0 - t)
	source.modulate = s

	var d := _destination_start_modulate
	d.a = _destination_start_modulate.a * t
	destination.modulate = d
	var start_pos := _source_position + _source_anchor_local - _destination_anchor_local if _has_match_hint() else _source_position
	destination.position = _curve_interp(start_pos, _destination_position, t, path_arc)


func _has_match_hint() -> bool:
	if not matched_keys.is_empty() or not key_map.is_empty():
		return true
	return not _pick_best_common_token(source, destination).is_empty()


func _curve_interp(a: Vector2, b: Vector2, t: float, arc: float) -> Vector2:
	var mid := a.lerp(b, 0.5)
	var dir := (b - a).normalized()
	var normal := Vector2(-dir.y, dir.x)
	var control := mid + normal * arc * 0.2 * (b - a).length()
	var p0 := a.lerp(control, t)
	var p1 := control.lerp(b, t)
	return p0.lerp(p1, t)


func _pick_source_anchor(src_text: String) -> String:
	if not matched_keys.is_empty():
		for k in matched_keys:
			if src_text.find(k) >= 0:
				return k
	if not key_map.is_empty():
		for k in key_map.keys():
			var sk := str(k)
			var mapped := str(key_map[k])
			if src_text.find(sk) >= 0 and destination != null and destination.text.find(mapped) >= 0:
				return sk
			if src_text.find(sk) >= 0:
				return sk
	var best_common: String = _pick_best_common_token(source, destination)
	if not best_common.is_empty():
		return best_common
	return ""


func _pick_destination_anchor(dst_text: String) -> String:
	if not matched_keys.is_empty():
		for k in matched_keys:
			if dst_text.find(k) >= 0:
				return k
	if not key_map.is_empty():
		for k in key_map.keys():
			var mapped := str(key_map[k])
			if dst_text.find(mapped) >= 0:
				return mapped
	var src_anchor := _pick_source_anchor(source.text if source != null else "")
	return src_anchor


func _extract_match_tokens(text_mob: LsgTextMobject) -> PackedStringArray:
	if text_mob == null:
		return PackedStringArray()
	var out: PackedStringArray = PackedStringArray()
	if text_mob.has_method("get_match_tokens"):
		var tokens: Variant = text_mob.call("get_match_tokens")
		if tokens is PackedStringArray:
			for token in (tokens as PackedStringArray):
				_append_token_variants(out, token)
		elif tokens is Array:
			for token in PackedStringArray(tokens):
				_append_token_variants(out, token)
	var fallback_tokens: PackedStringArray = _split_tokens_from_text(text_mob.text)
	for token in fallback_tokens:
		_append_token_variants(out, token)
	return out


func _estimate_anchor_offset(text_mob: LsgTextMobject, token: String) -> Vector2:
	if text_mob == null:
		return Vector2.ZERO
	var full_text: String = text_mob.text
	if token.is_empty():
		return Vector2.ZERO
	var idx: int = _find_token_index(full_text, token)
	if idx < 0:
		return Vector2.ZERO
	var line_col: Vector2i = _line_col_for_index(full_text, idx)
	var char_w: float = _estimate_char_width(text_mob)
	var line_h: float = _estimate_line_height(text_mob)
	return Vector2(float(line_col.y) * char_w, float(line_col.x) * line_h)


func _estimate_char_width(text_mob: LsgTextMobject) -> float:
	return maxf(6.0, float(text_mob.font_size) * 0.52)


func _estimate_line_height(text_mob: LsgTextMobject) -> float:
	return maxf(10.0, float(text_mob.font_size) * 1.22)


func _split_tokens_from_text(text: String) -> PackedStringArray:
	var out: PackedStringArray = PackedStringArray()
	var current: String = ""
	for i in range(text.length()):
		var ch: String = text.substr(i, 1)
		var split: bool = TOKEN_SPLITTERS.has(ch)
		if split:
			_append_if_new(out, current.strip_edges())
			current = ""
			continue
		current += ch
	_append_if_new(out, current.strip_edges())
	return out


func _append_token_variants(out: PackedStringArray, token: String) -> void:
	var clean: String = token.strip_edges()
	if clean.is_empty():
		return
	_append_if_new(out, clean)
	var normalized: String = _normalize_token(clean)
	_append_if_new(out, normalized)


func _append_if_new(out: PackedStringArray, token: String) -> void:
	if token.length() < 1:
		return
	if not out.has(token):
		out.append(token)


func _normalize_token(token: String) -> String:
	var out: String = token
	var drop_chars: PackedStringArray = PackedStringArray([" ", "\n", "\t", "(", ")", "[", "]", "{", "}", ",", ":", ";", "^", "_"])
	for ch in drop_chars:
		out = out.replace(ch, "")
	return out.strip_edges().to_lower()


func _pick_best_common_token(src_mob: LsgTextMobject, dst_mob: LsgTextMobject) -> String:
	if src_mob == null or dst_mob == null:
		return ""
	var src_tokens: PackedStringArray = _extract_match_tokens(src_mob)
	var dst_tokens: PackedStringArray = _extract_match_tokens(dst_mob)
	if src_tokens.is_empty() or dst_tokens.is_empty():
		return ""

	var best_token: String = ""
	var best_score: int = -1
	for token in src_tokens:
		if not dst_tokens.has(token):
			continue
		var score: int = _token_strength(token)
		if score > best_score:
			best_score = score
			best_token = token
	return best_token


func _token_strength(token: String) -> int:
	var normalized: String = _normalize_token(token)
	var length_score: int = normalized.length()
	var bonus: int = 0
	if _contains_ascii_digit(normalized):
		bonus += 1
	if _contains_ascii_letter(normalized):
		bonus += 1
	return length_score * 4 + bonus


func _contains_ascii_letter(s: String) -> bool:
	for i in range(s.length()):
		var ch: String = s.substr(i, 1)
		if (ch >= "a" and ch <= "z") or (ch >= "A" and ch <= "Z"):
			return true
	return false


func _contains_ascii_digit(s: String) -> bool:
	for i in range(s.length()):
		var ch: String = s.substr(i, 1)
		if ch >= "0" and ch <= "9":
			return true
	return false


func _find_token_index(text: String, token: String) -> int:
	var raw_idx: int = text.find(token)
	if raw_idx >= 0:
		return raw_idx
	var n_token: String = _normalize_token(token)
	if n_token.is_empty():
		return -1
	for i in range(text.length()):
		for j in range(i + 1, text.length() + 1):
			var chunk: String = text.substr(i, j - i)
			if _normalize_token(chunk) == n_token:
				return i
	return -1


func _line_col_for_index(text: String, idx: int) -> Vector2i:
	var line: int = 0
	var col: int = 0
	var stop: int = clampi(idx, 0, text.length())
	for i in range(stop):
		var ch: String = text.substr(i, 1)
		if ch == "\n":
			line += 1
			col = 0
		else:
			col += 1
	return Vector2i(line, col)
