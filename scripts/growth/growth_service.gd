extends RefCounted
class_name GrowthService

const AbilityData = preload("res://scripts/domain/ability_data.gd")
const CharacterData = preload("res://scripts/domain/character_data.gd")

var _database
var _rng: RandomNumberGenerator


func _init(database, rng: RandomNumberGenerator) -> void:
	_database = database
	_rng = rng


func apply_victory_growth(allies: Array[CharacterData]) -> Array[String]:
	var logs: Array[String] = []
	for character in allies:
		if not character.is_alive:
			continue
		match character.race:
			CharacterData.RACE_HUMAN:
				logs.append_array(_grow_human(character))
			CharacterData.RACE_ESPER:
				logs.append_array(_grow_esper(character))
	return logs


func _grow_human(character: CharacterData) -> Array[String]:
	var logs: Array[String] = []
	var gains: Array[String] = []

	if _roll_growth(0.45, character.usage_stats.get("attack", 0), 0.08):
		character.max_hp += 2
		character.hp += 2
		gains.append("Max HP +2")
	if _roll_growth(0.35, character.usage_stats.get("attack", 0), 0.12):
		character.str += 1
		gains.append("STR +1")
	if _roll_growth(0.30, character.usage_stats.get("defend", 0), 0.12):
		character.def += 1
		gains.append("DEF +1")
	if _roll_growth(0.25, character.usage_stats.get("attack", 0), 0.05):
		character.agi += 1
		gains.append("AGI +1")

	character.base_stats = {
		"max_hp": character.max_hp,
		"str": character.str,
		"def": character.def,
		"agi": character.agi,
		"magic": character.magic,
	}
	character.reset_usage_stats()

	if gains.is_empty():
		logs.append("%s feels more seasoned, but gains no stat increase." % character.name)
	else:
		logs.append("%s grows: %s." % [character.name, ", ".join(gains)])
	return logs


func _grow_esper(character: CharacterData) -> Array[String]:
	var logs: Array[String] = []
	if _rng.randf() > 0.65:
		logs.append("%s reflects on the battle, but learns nothing new." % character.name)
		character.reset_usage_stats()
		return logs

	var learnable: Array[Dictionary] = _database.get_esper_learn_pool()
	var ability_dict: Dictionary = learnable[_rng.randi_range(0, learnable.size() - 1)]
	var new_ability := AbilityData.new(ability_dict)

	for ability in character.abilities:
		if ability.id == new_ability.id:
			logs.append("%s focuses their talent, but %s was already known." % [character.name, new_ability.name])
			character.reset_usage_stats()
			return logs

	if character.abilities.size() >= 4:
		var removed: AbilityData = character.abilities.pop_front()
		logs.append("%s forgets %s." % [character.name, removed.name])

	character.abilities.append(new_ability)
	logs.append("%s learned %s." % [character.name, new_ability.name])
	character.reset_usage_stats()
	return logs


func _roll_growth(base_chance: float, related_actions: int, per_action_bonus: float) -> bool:
	return _rng.randf() < base_chance + float(related_actions) * per_action_bonus
