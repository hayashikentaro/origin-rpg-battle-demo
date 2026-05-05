extends RefCounted
class_name FrontendBattleController

const CoreBridge = preload("res://scripts/frontend/core_bridge.gd")

var _bridge := CoreBridge.new()
var _state: Dictionary = {}
var _last_actor_resolve_result: Dictionary = {}


func _init() -> void:
	_restart_battle()


func get_party_members() -> Array:
	return _state.get("allies", [])


func get_enemy_members() -> Array:
	return _state.get("enemies", [])


func get_battle_log() -> Array[String]:
	var logs: Array[String] = []
	for line in _state.get("battleLog", []):
		logs.append(str(line))
	return logs


func get_state() -> String:
	return str(_state.get("state", ""))


func get_last_actor_resolve_result() -> Dictionary:
	return _last_actor_resolve_result.duplicate(true)


func get_turn_number() -> int:
	return int(_state.get("turnNumber", 1))


func get_current_actor() -> Dictionary:
	var living := _living_allies()
	var index := int(_state.get("currentActorIndex", 0))
	if get_state() != "command" or living.is_empty() or index >= living.size():
		return {}
	return living[index]


func can_use_ability(character: Dictionary) -> bool:
	return not character.get("abilities", []).is_empty()


func queue_attack() -> void:
	_apply_request({"operation": "queue_action", "state": _state, "actionType": "attack"})


func queue_defend() -> void:
	_apply_request({"operation": "queue_action", "state": _state, "actionType": "defend"})


func queue_ability(ability_index: int) -> void:
	_apply_request({"operation": "queue_action", "state": _state, "actionType": "ability", "abilityIndex": ability_index})


func resolve_next_step() -> void:
	_apply_request({"operation": "resolve_next", "state": _state})


func get_status_summary() -> String:
	match get_state():
		"command":
			var actor := get_current_actor()
			if actor.is_empty():
				return "%dターン目の行動入力完了。次へ進んでください。" % get_turn_number()
			return "%dターン目: %sの行動を選んでください。" % [get_turn_number(), actor.get("name", "")]
		"victory_meat":
			var monster := _find_pending_monster()
			var pending_index := int(_state.get("pendingMeatIndex", -1))
			var drops: Array = _state.get("meatDrops", [])
			if not monster.is_empty() and pending_index >= 0 and pending_index < drops.size():
				return "勝利。%sは%sを食べられます。" % [monster.get("name", ""), drops[pending_index].get("name", "")]
			return "勝利後処理が完了しました。"
		"victory_done":
			return "勝利。次へ進むとデモバトルを最初からやり直します。"
		"defeat":
			return "全滅。次へ進むとデモバトルを最初からやり直します。"
		"finished":
			return "次へ進むとデモバトルを最初からやり直します。"
	return ""


func get_pending_meat_label() -> String:
	var pending_index := int(_state.get("pendingMeatIndex", -1))
	var drops: Array = _state.get("meatDrops", [])
	if get_state() != "victory_meat" or pending_index < 0 or pending_index >= drops.size():
		return ""
	return "%sを食べる" % drops[pending_index].get("name", "")


func can_eat_meat() -> bool:
	return get_state() == "victory_meat" and not _find_pending_monster().is_empty()


func consume_pending_meat() -> void:
	_apply_request({"operation": "consume_meat", "state": _state})


func preview_current_actor_attack() -> Dictionary:
	return preview_current_actor_action("attack")


func preview_current_actor_defend() -> Dictionary:
	return preview_current_actor_action("defend")


func preview_current_actor_pointer_probe() -> Dictionary:
	return preview_current_actor_action("pointer_probe")


func preview_current_actor_ability(ability_index: int = 0) -> Dictionary:
	return preview_current_actor_action("ability", ability_index)


func preview_current_actor_commands() -> Array:
	var actor := get_current_actor()
	if actor.is_empty():
		return []
	var command_inputs: Array = []
	var labels: Array[String] = []
	command_inputs.append(_build_command_input("attack", 0, actor))
	labels.append("ATK")
	command_inputs.append(_build_command_input("defend", 0, actor))
	labels.append("DEF")
	command_inputs.append(_build_command_input("pointer_probe", 0, actor))
	labels.append("PTR")
	var abilities: Array = actor.get("abilities", [])
	for index in range(abilities.size()):
		command_inputs.append(_build_command_input("ability", index, actor))
		labels.append("ABL%s:%s" % [index, str(abilities[index].get("name", "ABILITY"))])
	var response := _bridge.resolve_actor_command_matrix(command_inputs)
	if not response.get("ok", false):
		push_error(str(response.get("error", "Unknown TypeScript core error.")))
		return []
	var results: Array = response.get("actorResolveResults", [])
	var previews: Array = []
	for index in range(mini(labels.size(), results.size())):
		previews.append({
			"label": labels[index],
			"result": results[index],
		})
	return previews


func preview_current_actor_abilities() -> Array:
	var actor := get_current_actor()
	if actor.is_empty():
		return []
	var previews: Array = []
	var abilities: Array = actor.get("abilities", [])
	for index in range(abilities.size()):
		var ability: Dictionary = abilities[index]
		previews.append({
			"label": "ABL%s:%s" % [index, str(ability.get("name", "ABILITY"))],
			"result": preview_current_actor_ability(index),
		})
	return previews


func preview_current_actor_action(action_type: String, ability_index: int = 0) -> Dictionary:
	var actor := get_current_actor()
	if actor.is_empty():
		return {}
	return _resolve_actor_command(_build_command_input(action_type, ability_index, actor))


func _restart_battle() -> void:
	_last_actor_resolve_result = {}
	_apply_request({"operation": "init"})


func _apply_request(request: Dictionary) -> void:
	var response := _bridge.call_core(request)
	if not response.get("ok", false):
		push_error(str(response.get("error", "Unknown TypeScript core error.")))
		return
	_state = response.get("state", {})


func _resolve_actor_command(command_input: Dictionary) -> Dictionary:
	var response := _bridge.resolve_actor_command(command_input)
	if not response.get("ok", false):
		push_error(str(response.get("error", "Unknown TypeScript core error.")))
		return {}
	_last_actor_resolve_result = response.get("actorResolveResult", {})
	return _last_actor_resolve_result.duplicate(true)


func _living_allies() -> Array:
	var living: Array = []
	for ally in _state.get("allies", []):
		if ally.get("isAlive", false):
			living.append(ally)
	return living


func _find_pending_monster() -> Dictionary:
	var pending_id := str(_state.get("pendingMonsterId", ""))
	if pending_id.is_empty():
		return {}
	for ally in _state.get("allies", []):
		if ally.get("id", "") == pending_id:
			return ally
	return {}


func _build_command_input(action_type: String, ability_index: int, actor: Dictionary) -> Dictionary:
	var actor_index := int(_state.get("currentActorIndex", 0))
	return {
		"actorIndex": actor_index,
		"action": _build_preview_action_head(action_type, ability_index, actor),
		"outcomeLikeByte": 0,
	}


func _build_preview_action_head(action_type: String, ability_index: int, actor: Dictionary) -> Dictionary:
	match action_type:
		"attack":
			return {
				"kindId": 0x10,
				"arg": 0,
				"target": 0xFF,
				"slotIndex": 0,
			}
		"defend":
			return {
				"kindId": 0x04,
				"arg": 0,
				"target": 0x00,
				"slotIndex": 0,
			}
		"pointer_probe":
			return {
				"kindId": 0x01,
				"arg": 0,
				"target": 0xFF,
				"slotIndex": 0,
			}
		"ability":
			var abilities: Array = actor.get("abilities", [])
			if abilities.is_empty():
				return {
					"kindId": 0x20,
					"arg": 0,
					"target": 0xFF,
					"slotIndex": 0,
				}
			var clamped_index := clampi(ability_index, 0, abilities.size() - 1)
			return {
				"kindId": 0x20,
				"arg": clamped_index,
				"target": 0xFF,
				"slotIndex": clamped_index,
			}
	return {
		"kindId": 0x00,
		"arg": 0,
		"target": 0xFF,
		"slotIndex": 0,
	}
