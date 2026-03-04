class_name PortTransformMatchingText
extends PortAnimation

var source: PortTextMobject
var destination: PortTextMobject
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
	p_source: PortTextMobject,
	p_destination: PortTextMobject,
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
	var src_tokens := _extract_match_tokens(source)
	var dst_tokens := _extract_match_tokens(destination)
	for token in src_tokens:
		if dst_tokens.has(token):
			return true
	return false


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
			if src_text.find(sk) >= 0:
				return sk
	var src_tokens := _extract_match_tokens(source)
	var dst_tokens := _extract_match_tokens(destination)
	for token in src_tokens:
		if dst_tokens.has(token):
			return token
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


func _extract_match_tokens(text_mob: PortTextMobject) -> PackedStringArray:
	if text_mob == null:
		return PackedStringArray()
	if text_mob.has_method("get_match_tokens"):
		var tokens = text_mob.call("get_match_tokens")
		if tokens is PackedStringArray:
			return tokens
		if tokens is Array:
			return PackedStringArray(tokens)
	var fallback := PackedStringArray()
	for part in text_mob.text.replace("\n", " ").split(" ", false):
		var clean := part.strip_edges()
		if clean.length() >= 2:
			fallback.append(clean)
	return fallback


func _estimate_anchor_offset(text_mob: PortTextMobject, token: String) -> Vector2:
	if text_mob == null:
		return Vector2.ZERO
	var full_text := text_mob.text
	if token.is_empty():
		return Vector2.ZERO
	var idx := full_text.find(token)
	if idx < 0:
		return Vector2.ZERO
	var char_w := _estimate_char_width(text_mob)
	return Vector2(float(idx) * char_w, 0.0)


func _estimate_char_width(text_mob: PortTextMobject) -> float:
	return maxf(6.0, float(text_mob.font_size) * 0.52)
