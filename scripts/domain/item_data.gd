extends RefCounted
class_name ItemData

var id: String
var name: String
var stat_bonuses: Dictionary


func _init(data: Dictionary = {}) -> void:
	id = data.get("id", "")
	name = data.get("name", id.capitalize())
	stat_bonuses = data.get("stat_bonuses", {}).duplicate(true)


func to_dict() -> Dictionary:
	return {
		"id": id,
		"name": name,
		"stat_bonuses": stat_bonuses.duplicate(true),
	}
