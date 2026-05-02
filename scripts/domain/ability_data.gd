extends RefCounted
class_name AbilityData

var id: String
var name: String
var power: int
var kind: String
var target_side: String


func _init(data: Dictionary = {}) -> void:
	id = data.get("id", "")
	name = data.get("name", id.capitalize())
	power = data.get("power", 0)
	kind = data.get("kind", "attack")
	target_side = data.get("target_side", "enemy")


func to_dict() -> Dictionary:
	return {
		"id": id,
		"name": name,
		"power": power,
		"kind": kind,
		"target_side": target_side,
	}
