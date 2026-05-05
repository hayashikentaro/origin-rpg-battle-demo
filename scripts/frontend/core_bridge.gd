extends RefCounted
class_name CoreBridge

const REQUEST_PATH := "user://core_request.json"
const RESPONSE_PATH := "user://core_response.json"


func call_core(request: Dictionary) -> Dictionary:
	var request_file := ProjectSettings.globalize_path(REQUEST_PATH)
	var response_file := ProjectSettings.globalize_path(RESPONSE_PATH)
	var write_handle := FileAccess.open(request_file, FileAccess.WRITE)
	if write_handle == null:
		return {"ok": false, "error": "Could not write core request file."}
	write_handle.store_string(JSON.stringify(request))
	write_handle.close()

	var output: Array = []
	var exit_code := OS.execute(_resolve_node_path(), [_resolve_cli_path(), request_file, response_file], output, true, false)
	if exit_code != 0:
		return {
			"ok": false,
			"error": "TypeScript core exited with code %d.\n%s" % [exit_code, "\n".join(output)],
		}

	if not FileAccess.file_exists(response_file):
		return {"ok": false, "error": "TypeScript core did not produce a response file."}

	var read_handle := FileAccess.open(response_file, FileAccess.READ)
	if read_handle == null:
		return {"ok": false, "error": "Could not read core response file."}
	var parsed = JSON.parse_string(read_handle.get_as_text())
	read_handle.close()
	if typeof(parsed) != TYPE_DICTIONARY:
		return {"ok": false, "error": "Invalid response from TypeScript core."}
	return parsed


func resolve_actor_command(command_input: Dictionary) -> Dictionary:
	return call_core({
		"operation": "resolve_actor_command",
		"commandInput": command_input,
	})


func resolve_actor_command_matrix(command_inputs: Array) -> Dictionary:
	return call_core({
		"operation": "resolve_actor_command_matrix",
		"commandInputs": command_inputs,
	})


func _resolve_cli_path() -> String:
	return ProjectSettings.globalize_path("res://core/dist/cli.js")


func _resolve_node_path() -> String:
	var home := OS.get_environment("HOME")
	var candidates := [
		home.path_join(".volta/bin/node"),
		home.path_join(".nodenv/shims/node"),
		"/opt/homebrew/bin/node",
		"/usr/local/bin/node",
	]
	for candidate in candidates:
		if FileAccess.file_exists(candidate):
			return candidate
	return "node"
