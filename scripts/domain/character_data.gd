extends RefCounted
class_name CharacterData

const AbilityData = preload("res://scripts/domain/ability_data.gd")
const ItemData = preload("res://scripts/domain/item_data.gd")

const RACE_HUMAN := "Human"
const RACE_ESPER := "Esper"
const RACE_MONSTER := "Monster"
const RACE_ROBOT := "Robot"

var id: String
var name: String
var race: String
var form: String
var hp: int
var max_hp: int
var str: int
var def: int
var agi: int
var magic: int
var abilities: Array[AbilityData] = []
var equipment: Array[ItemData] = []
var base_stats: Dictionary = {}
var equipment_stats: Dictionary = {}
var is_alive: bool = true
var usage_stats: Dictionary = {}


func _init(data: Dictionary = {}) -> void:
	id = data.get("id", "")
	name = data.get("name", "")
	race = data.get("race", RACE_HUMAN)
	form = data.get("form", "")
	max_hp = data.get("max_hp", 1)
	hp = clampi(data.get("hp", max_hp), 0, max_hp)
	str = data.get("str", 1)
	def = data.get("def", 1)
	agi = data.get("agi", 1)
	magic = data.get("magic", 0)
	is_alive = data.get("is_alive", hp > 0)
	base_stats = data.get("base_stats", {
		"max_hp": max_hp,
		"str": str,
		"def": def,
		"agi": agi,
		"magic": magic,
	}).duplicate(true)
	equipment_stats = data.get("equipment_stats", {
		"max_hp": 0,
		"str": 0,
		"def": 0,
		"agi": 0,
		"magic": 0,
	}).duplicate(true)
	usage_stats = data.get("usage_stats", {
		"attack": 0,
		"defend": 0,
		"ability": 0,
	}).duplicate(true)

	for ability_dict in data.get("abilities", []):
		if ability_dict is AbilityData:
			abilities.append(AbilityData.new(ability_dict.to_dict()))
		else:
			abilities.append(AbilityData.new(ability_dict))

	for item_dict in data.get("equipment", []):
		if item_dict is ItemData:
			equipment.append(ItemData.new(item_dict.to_dict()))
		else:
			equipment.append(ItemData.new(item_dict))


func to_dict() -> Dictionary:
	var ability_dicts: Array = []
	for ability in abilities:
		ability_dicts.append(ability.to_dict())

	var equipment_dicts: Array = []
	for item in equipment:
		equipment_dicts.append(item.to_dict())

	return {
		"id": id,
		"name": name,
		"race": race,
		"form": form,
		"hp": hp,
		"max_hp": max_hp,
		"str": str,
		"def": def,
		"agi": agi,
		"magic": magic,
		"abilities": ability_dicts,
		"equipment": equipment_dicts,
		"base_stats": base_stats.duplicate(true),
		"equipment_stats": equipment_stats.duplicate(true),
		"is_alive": is_alive,
		"usage_stats": usage_stats.duplicate(true),
	}


func apply_damage(amount: int) -> int:
	var applied := maxi(0, amount)
	hp = maxi(0, hp - applied)
	is_alive = hp > 0
	return applied


func heal(amount: int) -> int:
	var applied := maxi(0, amount)
	hp = mini(max_hp, hp + applied)
	is_alive = hp > 0
	return applied


func set_stats_from_dict(stats: Dictionary) -> void:
	max_hp = int(stats.get("max_hp", max_hp))
	str = int(stats.get("str", str))
	def = int(stats.get("def", def))
	agi = int(stats.get("agi", agi))
	magic = int(stats.get("magic", magic))
	hp = clampi(hp, 0, max_hp)
	is_alive = hp > 0


func reset_usage_stats() -> void:
	usage_stats = {
		"attack": 0,
		"defend": 0,
		"ability": 0,
	}


func record_action(action_type: String) -> void:
	usage_stats[action_type] = int(usage_stats.get(action_type, 0)) + 1
