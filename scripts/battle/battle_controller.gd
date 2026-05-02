extends RefCounted
class_name BattleController

const AbilityData = preload("res://scripts/domain/ability_data.gd")
const BattleUnit = preload("res://scripts/domain/battle_unit.gd")
const CharacterData = preload("res://scripts/domain/character_data.gd")
const DemoDatabase = preload("res://scripts/data/demo_database.gd")
const GrowthService = preload("res://scripts/growth/growth_service.gd")
const MonsterTransformService = preload("res://scripts/growth/monster_transform_service.gd")
const RobotEquipmentService = preload("res://scripts/growth/robot_equipment_service.gd")
const TurnResolver = preload("res://scripts/battle/turn_resolver.gd")

var database := DemoDatabase.new()
var rng := RandomNumberGenerator.new()
var growth_service := GrowthService.new(database, rng)
var transform_service := MonsterTransformService.new(database)
var robot_service := RobotEquipmentService.new()

var allies: Array[BattleUnit] = []
var enemies: Array[BattleUnit] = []
var battle_log: Array[String] = []
var queued_actions: Array[Dictionary] = []
var state: String = "command"
var turn_number: int = 1
var current_actor_index: int = 0
var meat_drops: Array[Dictionary] = []
var victory_growth_logs: Array[String] = []
var pending_monster: CharacterData = null
var pending_meat_index: int = -1


func _init() -> void:
	rng.randomize()
	_start_demo_battle()


func _start_demo_battle() -> void:
	allies.clear()
	enemies.clear()
	battle_log.clear()
	queued_actions.clear()
	meat_drops.clear()
	victory_growth_logs.clear()
	state = "command"
	turn_number = 1
	current_actor_index = 0
	pending_meat_index = -1
	pending_monster = null

	for ally in database.create_allies():
		robot_service.apply_equipment_stats(ally)
		ally.reset_usage_stats()
		allies.append(BattleUnit.new(ally, "ally"))

	for enemy in database.create_enemies():
		enemies.append(BattleUnit.new(enemy, "enemy"))

	battle_log.append("Battle demo begins.")
	battle_log.append("Choose commands for each ally, then resolve the turn.")


func get_party_members() -> Array[CharacterData]:
	var members: Array[CharacterData] = []
	for unit in allies:
		members.append(unit.character)
	return members


func get_enemy_members() -> Array[CharacterData]:
	var members: Array[CharacterData] = []
	for unit in enemies:
		members.append(unit.character)
	return members


func get_battle_log() -> Array[String]:
	return battle_log.duplicate()


func get_state() -> String:
	return state


func get_turn_number() -> int:
	return turn_number


func get_current_actor() -> CharacterData:
	var living_allies := _living_allies()
	if state != "command" or living_allies.is_empty() or current_actor_index >= living_allies.size():
		return null
	return living_allies[current_actor_index]


func can_use_ability(character: CharacterData) -> bool:
	return not character.abilities.is_empty()


func queue_attack() -> void:
	_queue_action_for_current("attack")


func queue_defend() -> void:
	_queue_action_for_current("defend")


func queue_ability(ability_index: int) -> void:
	var actor := get_current_actor()
	if actor == null:
		return
	if ability_index < 0 or ability_index >= actor.abilities.size():
		return
	_queue_action_for_current("ability", actor.abilities[ability_index])


func resolve_next_step() -> void:
	match state:
		"command":
			if current_actor_index >= _living_allies().size():
				_resolve_turn()
		"victory_meat":
			_skip_meat_choice()
		"victory_done", "defeat", "finished":
			_start_demo_battle()


func get_status_summary() -> String:
	match state:
		"command":
			var actor := get_current_actor()
			if actor == null:
				return "All ally commands locked in. Press Next to resolve turn %d." % turn_number
			return "Turn %d: choose %s's action." % [turn_number, actor.name]
		"victory_meat":
			if pending_monster != null and pending_meat_index >= 0 and pending_meat_index < meat_drops.size():
				return "Victory. %s may eat %s." % [pending_monster.name, meat_drops[pending_meat_index]["name"]]
			return "Victory growth complete."
		"victory_done":
			return "Victory. Press Next to restart the demo battle."
		"defeat":
			return "Party defeated. Press Next to restart the demo battle."
	return ""


func get_pending_meat_label() -> String:
	if state != "victory_meat" or pending_meat_index < 0 or pending_meat_index >= meat_drops.size():
		return ""
	return "Eat %s" % meat_drops[pending_meat_index]["name"]


func can_eat_meat() -> bool:
	return state == "victory_meat" and pending_monster != null and pending_meat_index >= 0


func consume_pending_meat() -> void:
	if not can_eat_meat():
		return
	var meat := meat_drops[pending_meat_index]
	battle_log.append("%s eats %s." % [pending_monster.name, meat["name"]])
	var result := transform_service.transform(pending_monster, meat["type"])
	if result.is_empty():
		battle_log.append("Nothing changes.")
	else:
		battle_log.append("%s transformed into %s." % [pending_monster.name, result["form"]])
	advance_victory_flow()


func advance_victory_flow() -> void:
	if state == "victory_meat":
		pending_meat_index += 1
		_prepare_next_meat_choice()
		return
	if state == "victory_done" or state == "defeat":
		state = "finished"


func get_victory_growth_logs() -> Array[String]:
	return victory_growth_logs.duplicate()


func _queue_action_for_current(action_type: String, ability: AbilityData = null) -> void:
	var actor := get_current_actor()
	if actor == null:
		return
	actor.record_action(action_type)
	queued_actions.append({
		"actor": actor,
		"type": action_type,
		"ability": ability,
		"side": "ally",
	})
	if ability == null:
		battle_log.append("%s prepares %s." % [actor.name, action_type])
	else:
		battle_log.append("%s prepares %s." % [actor.name, ability.name])
	current_actor_index += 1
	if current_actor_index >= _living_allies().size():
		battle_log.append("All commands set. Press Next to resolve.")


func _resolve_turn() -> void:
	_queue_enemy_actions()
	var all_actions := queued_actions.duplicate()
	all_actions.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return int(a["actor"].agi) > int(b["actor"].agi)
	)
	for action in all_actions:
		if action.get("type") == "defend":
			var actor: CharacterData = action["actor"]
			actor.def += 2
		var action_logs := TurnResolver.resolve_action(action, allies, enemies, rng)
		battle_log.append_array(action_logs)
		if action.get("type") == "defend":
			var actor_reset: CharacterData = action["actor"]
			actor_reset.def -= 2
		if _all_dead(enemies):
			_handle_victory()
			return
		if _all_dead(allies):
			state = "defeat"
			battle_log.append("The party falls in battle.")
			return
	queued_actions.clear()
	current_actor_index = 0
	turn_number += 1
	battle_log.append("Turn %d begins." % turn_number)


func _queue_enemy_actions() -> void:
	for unit in enemies:
		if not unit.is_alive():
			continue
		var action_type := "attack"
		var ability: AbilityData = null
		if not unit.character.abilities.is_empty() and rng.randf() < 0.4:
			action_type = "ability"
			ability = unit.character.abilities[0]
		queued_actions.append({
			"actor": unit.character,
			"type": action_type,
			"ability": ability,
			"side": "enemy",
		})


func _handle_victory() -> void:
	state = "victory_meat"
	queued_actions.clear()
	victory_growth_logs = growth_service.apply_victory_growth(get_party_members())
	battle_log.append("Enemies defeated.")
	battle_log.append_array(victory_growth_logs)
	meat_drops.clear()
	for unit in enemies:
		var drop := database.get_enemy_meat_drop(unit.character.id)
		if not drop.is_empty():
			meat_drops.append(drop)
	pending_monster = _find_monster_ally()
	pending_meat_index = 0
	_prepare_next_meat_choice()


func _prepare_next_meat_choice() -> void:
	if pending_monster == null or not pending_monster.is_alive:
		state = "victory_done"
		battle_log.append("No monster is available to eat meat.")
		return
	while pending_meat_index < meat_drops.size():
		var meat := meat_drops[pending_meat_index]
		if transform_service.can_transform(pending_monster, meat["type"]):
			state = "victory_meat"
			battle_log.append("%s can eat %s." % [pending_monster.name, meat["name"]])
			return
		pending_meat_index += 1
	state = "victory_done"
	battle_log.append("No further monster transformations are available.")


func _skip_meat_choice() -> void:
	if state != "victory_meat":
		return
	var meat := meat_drops[pending_meat_index]
	battle_log.append("%s leaves %s behind." % [pending_monster.name, meat["name"]])
	advance_victory_flow()


func _living_allies() -> Array[CharacterData]:
	var living: Array[CharacterData] = []
	for unit in allies:
		if unit.is_alive():
			living.append(unit.character)
	return living


func _find_monster_ally() -> CharacterData:
	for unit in allies:
		if unit.character.race == CharacterData.RACE_MONSTER:
			return unit.character
	return null


func _all_dead(units: Array[BattleUnit]) -> bool:
	for unit in units:
		if unit.is_alive():
			return false
	return true
