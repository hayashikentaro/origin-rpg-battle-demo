extends RefCounted
class_name MonsterTransformService

const AbilityData = preload("res://scripts/domain/ability_data.gd")
const CharacterData = preload("res://scripts/domain/character_data.gd")

var _database


func _init(database) -> void:
	_database = database


func can_transform(character: CharacterData, meat_type: String) -> bool:
	if character.race != CharacterData.RACE_MONSTER:
		return false
	return _database.get_monster_transformation(character.form, meat_type).size() > 0


func transform(character: CharacterData, meat_type: String) -> Dictionary:
	var form_data: Dictionary = _database.get_monster_transformation(character.form, meat_type)
	if form_data.is_empty():
		return {}

	character.form = form_data.get("form", character.form)
	character.name = form_data.get("display_name", character.name)
	character.base_stats = form_data.get("stats", {}).duplicate(true)
	character.set_stats_from_dict(character.base_stats)
	character.hp = character.max_hp
	character.abilities.clear()
	for ability_dict in form_data.get("abilities", []):
		character.abilities.append(AbilityData.new(ability_dict))
	character.is_alive = true
	return form_data
