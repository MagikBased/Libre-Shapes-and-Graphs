class_name LsgTexToolchainSpike
extends RefCounted

const LATEX_CANDIDATES: Array[String] = ["latex"]
const DVISVGM_CANDIDATES: Array[String] = ["dvisvgm"]
const SPIKE_DIR: String = "user://tex_spike"
const CACHE_DIR: String = "cache"
const SPIKE_TEX_FILE: String = "source.tex"
const SPIKE_DVI_FILE: String = "source.dvi"
const SPIKE_SVG_FILE: String = "output.svg"
const SPIKE_META_FILE: String = "meta.json"
const CACHE_SCHEMA_VERSION: String = "phase9_cache_v1"

static var _probe_cache_ready: bool = false
static var _probe_cache: Dictionary = {}
static var _cache_hits: int = 0
static var _cache_misses: int = 0


static func probe_toolchain() -> Dictionary:
	if _probe_cache_ready:
		return _probe_cache.duplicate(true)
	var latex_cmd: String = _find_working_command(LATEX_CANDIDATES, ["--version"])
	var dvisvgm_cmd: String = _find_working_command(DVISVGM_CANDIDATES, ["--version"])
	var latex_ok: bool = not latex_cmd.is_empty()
	var dvisvgm_ok: bool = not dvisvgm_cmd.is_empty()
	_probe_cache = {
		"ok": latex_ok and dvisvgm_ok,
		"latex_ok": latex_ok,
		"dvisvgm_ok": dvisvgm_ok,
		"latex_command": latex_cmd,
		"dvisvgm_command": dvisvgm_cmd
	}
	_probe_cache_ready = true
	return _probe_cache.duplicate(true)


static func render_to_display(tex_source: String, force_external: bool = false, render_options: Dictionary = {}) -> Dictionary:
	var normalized_source: String = _normalize_tex_source(tex_source)
	var normalized_options: Dictionary = _normalize_options(render_options)
	var cache_key: String = _build_cache_key(normalized_source, normalized_options)
	var cache_paths: Dictionary = _build_cache_paths(cache_key)
	var cached_local_svg_path: String = str(cache_paths.get("local_svg_path", ""))
	var cached_abs_svg_path: String = str(cache_paths.get("abs_svg_path", ""))
	if FileAccess.file_exists(cached_abs_svg_path):
		_cache_hits += 1
		return {
			"ok": true,
			"engine": "latex+dvisvgm",
			"display": "[external-tex artifact: %s]" % cached_local_svg_path,
			"artifact_svg_path": cached_local_svg_path,
			"artifact_svg_abs_path": cached_abs_svg_path,
			"cache_hit": true,
			"cache_key": cache_key,
			"cache_schema": CACHE_SCHEMA_VERSION,
			"probe": probe_toolchain()
		}

	_cache_misses += 1
	var probe: Dictionary = probe_toolchain()
	if not bool(probe.get("ok", false)):
		var reason: String = "missing toolchain (latex + dvisvgm required)"
		return {
			"ok": false,
			"engine": "external-spike",
			"reason": reason,
			"display": "",
			"probe": probe,
			"force_external": force_external,
			"cache_hit": false,
			"cache_key": cache_key,
			"cache_schema": CACHE_SCHEMA_VERSION
		}
	return _run_external_pipeline(normalized_source, normalized_options, probe, cache_paths, cache_key)


static func _run_external_pipeline(
	normalized_source: String,
	normalized_options: Dictionary,
	probe: Dictionary,
	cache_paths: Dictionary,
	cache_key: String
) -> Dictionary:
	var abs_dir: String = ProjectSettings.globalize_path(SPIKE_DIR)
	var mk_err: Error = DirAccess.make_dir_recursive_absolute(abs_dir)
	if mk_err != OK:
		return {
			"ok": false,
			"engine": "external-spike",
			"reason": "failed to create spike directory",
			"error_code": int(mk_err),
			"probe": probe,
			"cache_hit": false,
			"cache_key": cache_key,
			"cache_schema": CACHE_SCHEMA_VERSION
		}

	var cache_abs_dir: String = str(cache_paths.get("abs_dir", ""))
	var mk_cache_err: Error = DirAccess.make_dir_recursive_absolute(cache_abs_dir)
	if mk_cache_err != OK:
		return {
			"ok": false,
			"engine": "external-spike",
			"reason": "failed to create cache directory",
			"error_code": int(mk_cache_err),
			"probe": probe,
			"cache_hit": false,
			"cache_key": cache_key,
			"cache_schema": CACHE_SCHEMA_VERSION
		}

	var tex_path: String = str(cache_paths.get("abs_tex_path", ""))
	var dvi_path: String = str(cache_paths.get("abs_dvi_path", ""))
	var svg_path: String = str(cache_paths.get("abs_svg_path", ""))
	var local_svg_path: String = str(cache_paths.get("local_svg_path", ""))
	var local_dir_path: String = str(cache_paths.get("local_dir", ""))
	var write_ok: bool = _write_tex_document(tex_path, normalized_source)
	if not write_ok:
		return {
			"ok": false,
			"engine": "external-spike",
			"reason": "failed to write tex document",
			"probe": probe,
			"cache_hit": false,
			"cache_key": cache_key,
			"cache_schema": CACHE_SCHEMA_VERSION
		}

	var latex_cmd: String = str(probe.get("latex_command", "latex"))
	var latex_output: Array = []
	var latex_args: Array[String] = [
		"-interaction=nonstopmode",
		"-halt-on-error",
		"-output-directory=" + cache_abs_dir,
		tex_path
	]
	var latex_code: int = OS.execute(latex_cmd, latex_args, latex_output, true, true)
	if latex_code != 0:
		return {
			"ok": false,
			"engine": "external-spike",
			"reason": "latex failed",
			"exit_code": latex_code,
			"log": _stringify_output_lines(latex_output),
			"probe": probe,
			"cache_hit": false,
			"cache_key": cache_key,
			"cache_schema": CACHE_SCHEMA_VERSION
		}

	var dvisvgm_cmd: String = str(probe.get("dvisvgm_command", "dvisvgm"))
	var dvisvgm_output: Array = []
	var dvisvgm_args: Array[String] = [
		"--no-fonts",
		"--exact",
		"-n",
		"-o",
		svg_path,
		dvi_path
	]
	var dvisvgm_code: int = OS.execute(dvisvgm_cmd, dvisvgm_args, dvisvgm_output, true, true)
	if dvisvgm_code != 0:
		return {
			"ok": false,
			"engine": "external-spike",
			"reason": "dvisvgm failed",
			"exit_code": dvisvgm_code,
			"log": _stringify_output_lines(dvisvgm_output),
			"probe": probe,
			"cache_hit": false,
			"cache_key": cache_key,
			"cache_schema": CACHE_SCHEMA_VERSION
		}

	_write_cache_metadata(local_dir_path, normalized_source, normalized_options, cache_key)
	return {
		"ok": true,
		"engine": "latex+dvisvgm",
		"display": "[external-tex artifact: %s]" % local_svg_path,
		"artifact_svg_path": local_svg_path,
		"artifact_svg_abs_path": svg_path,
		"probe": probe,
		"cache_hit": false,
		"cache_key": cache_key,
		"cache_schema": CACHE_SCHEMA_VERSION
	}


static func _write_tex_document(tex_path: String, tex_source: String) -> bool:
	var body: String = tex_source
	if not body.contains("\\begin{"):
		body = "\\[\n%s\n\\]" % body
	var doc: String = ""
	doc += "\\documentclass[preview]{standalone}\n"
	doc += "\\usepackage{amsmath,amssymb,mathtools,cancel}\n"
	doc += "\\begin{document}\n"
	doc += body + "\n"
	doc += "\\end{document}\n"
	var file: FileAccess = FileAccess.open(tex_path, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(doc)
	file.flush()
	return true


static func _find_working_command(candidates: Array[String], args: Array[String]) -> String:
	for cmd in candidates:
		if not _command_exists(cmd):
			continue
		var output: Array = []
		var code: int = OS.execute(cmd, args, output, true, true)
		if code == 0:
			return cmd
	return ""


static func _stringify_output_lines(lines: Array) -> String:
	var out: PackedStringArray = PackedStringArray()
	for line in lines:
		out.append(str(line))
	return "\n".join(out)


static func _command_exists(command_name: String) -> bool:
	var output: Array = []
	if OS.has_feature("windows"):
		# Use cmd/where lookup on Windows to avoid noisy spawn errors for missing commands.
		var code_where: int = OS.execute("cmd", ["/c", "where", command_name], output, true, true)
		return code_where == 0
	var code_which: int = OS.execute("which", [command_name], output, true, true)
	return code_which == 0


static func get_cache_stats() -> Dictionary:
	return {
		"hits": _cache_hits,
		"misses": _cache_misses
	}


static func _normalize_tex_source(tex_source: String) -> String:
	var out: String = tex_source.replace("\r\n", "\n")
	out = out.replace("\r", "\n")
	return out.strip_edges()


static func _normalize_options(options: Dictionary) -> Dictionary:
	var out: Dictionary = {}
	var keys: Array = options.keys()
	keys.sort()
	for key in keys:
		out[str(key)] = options[key]
	return out


static func _build_cache_key(normalized_source: String, normalized_options: Dictionary) -> String:
	var key_basis: String = CACHE_SCHEMA_VERSION + "\n" + normalized_source + "\n" + _stable_dictionary_string(normalized_options)
	return key_basis.sha256_text()


static func _build_cache_paths(cache_key: String) -> Dictionary:
	var local_dir: String = SPIKE_DIR.path_join(CACHE_DIR).path_join(cache_key)
	var abs_dir: String = ProjectSettings.globalize_path(local_dir)
	return {
		"local_dir": local_dir,
		"abs_dir": abs_dir,
		"local_tex_path": local_dir.path_join(SPIKE_TEX_FILE),
		"abs_tex_path": abs_dir.path_join(SPIKE_TEX_FILE),
		"local_dvi_path": local_dir.path_join(SPIKE_DVI_FILE),
		"abs_dvi_path": abs_dir.path_join(SPIKE_DVI_FILE),
		"local_svg_path": local_dir.path_join(SPIKE_SVG_FILE),
		"abs_svg_path": abs_dir.path_join(SPIKE_SVG_FILE),
		"local_meta_path": local_dir.path_join(SPIKE_META_FILE),
		"abs_meta_path": abs_dir.path_join(SPIKE_META_FILE)
	}


static func _stable_dictionary_string(dict_value: Dictionary) -> String:
	var keys: Array = dict_value.keys()
	keys.sort()
	var parts: PackedStringArray = PackedStringArray()
	for key in keys:
		var k: String = str(key)
		var v: Variant = dict_value[key]
		parts.append("%s=%s" % [k, _stable_variant_string(v)])
	return "{%s}" % ",".join(parts)


static func _stable_variant_string(value: Variant) -> String:
	if value is Dictionary:
		return _stable_dictionary_string(value as Dictionary)
	if value is Array:
		var array_value: Array = value as Array
		var items: PackedStringArray = PackedStringArray()
		for item in array_value:
			items.append(_stable_variant_string(item))
		return "[%s]" % ",".join(items)
	return str(value)


static func _write_cache_metadata(local_dir: String, normalized_source: String, normalized_options: Dictionary, cache_key: String) -> void:
	var local_meta_path: String = local_dir.path_join(SPIKE_META_FILE)
	var abs_meta_path: String = ProjectSettings.globalize_path(local_meta_path)
	var file: FileAccess = FileAccess.open(abs_meta_path, FileAccess.WRITE)
	if file == null:
		return
	var metadata: Dictionary = {
		"schema": CACHE_SCHEMA_VERSION,
		"cache_key": cache_key,
		"source": normalized_source,
		"render_options": normalized_options
	}
	file.store_string(JSON.stringify(metadata, "\t"))
	file.flush()
