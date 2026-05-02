extends RefCounted
class_name BattleUnit

const CharacterData = preload("res://scripts/domain/character_data.gd")

var character: CharacterData
var team: String


func _init(character_data: CharacterData, side: String) -> void:
	character = character_data
	team = side


func is_alive() -> bool:
	return character.is_alive
