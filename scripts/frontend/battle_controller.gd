extends RefCounted
class_name FrontendBattleController

const CoreBridge = preload("res://scripts/frontend/core_bridge.gd")

var _bridge := CoreBridge.new()
var _state: Dictionary = {}


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


func _restart_battle() -> void:
	_apply_request({"operation": "init"})


func _apply_request(request: Dictionary) -> void:
	var response := _bridge.call_core(request)
	if not response.get("ok", false):
		push_error(str(response.get("error", "Unknown TypeScript core error.")))
		return
	_state = response.get("state", {})


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
