extends RefCounted
class_name DemoDatabase

const CharacterData = preload("res://scripts/domain/character_data.gd")

var abilities := {
	"fire": {"id": "fire", "name": "Fire", "power": 6, "kind": "magic_attack", "target_side": "enemy"},
	"heal": {"id": "heal", "name": "Heal", "power": 5, "kind": "heal", "target_side": "ally"},
	"spark": {"id": "spark", "name": "Spark", "power": 8, "kind": "magic_attack", "target_side": "enemy"},
}

var equipment := {
	"servo_arm": {"id": "servo_arm", "name": "Servo Arm", "stat_bonuses": {"str": 3, "def": 1}},
	"gyro_shell": {"id": "gyro_shell", "name": "Gyro Shell", "stat_bonuses": {"max_hp": 6, "def": 2, "agi": 1}},
}

var monster_forms := {
	"Slime": {
		"display_name": "Noro",
		"stats": {"max_hp": 26, "str": 7, "def": 5, "agi": 6, "magic": 2},
		"abilities": [],
	},
	"Wolf": {
		"display_name": "Noro",
		"stats": {"max_hp": 31, "str": 10, "def": 6, "agi": 10, "magic": 2},
		"abilities": [{"id": "howl", "name": "Howl", "power": 7, "kind": "magic_attack", "target_side": "enemy"}],
	},
	"Ghost": {
		"display_name": "Noro",
		"stats": {"max_hp": 28, "str": 8, "def": 5, "agi": 9, "magic": 8},
		"abilities": [{"id": "chill", "name": "Chill", "power": 8, "kind": "magic_attack", "target_side": "enemy"}],
	},
	"Chimera": {
		"display_name": "Noro",
		"stats": {"max_hp": 38, "str": 12, "def": 8, "agi": 11, "magic": 6},
		"abilities": [{"id": "flare_breath", "name": "Flare Breath", "power": 10, "kind": "magic_attack", "target_side": "enemy"}],
	},
}

var monster_transforms := {
	"Slime": {
		"beast": "Wolf",
	},
	"Wolf": {
		"undead": "Ghost",
	},
	"Ghost": {
		"beast": "Chimera",
	},
}


func create_allies() -> Array[CharacterData]:
	return [
		CharacterData.new({
			"id": "aki",
			"name": "Aki",
			"race": CharacterData.RACE_HUMAN,
			"hp": 36,
			"max_hp": 36,
			"str": 11,
			"def": 8,
			"agi": 9,
			"magic": 1,
			"abilities": [],
		}),
		CharacterData.new({
			"id": "mira",
			"name": "Mira",
			"race": CharacterData.RACE_ESPER,
			"hp": 28,
			"max_hp": 28,
			"str": 6,
			"def": 6,
			"agi": 8,
			"magic": 10,
			"abilities": [abilities["fire"], abilities["heal"]],
		}),
		CharacterData.new({
			"id": "noro",
			"name": "Noro",
			"race": CharacterData.RACE_MONSTER,
			"form": "Slime",
			"hp": 26,
			"max_hp": 26,
			"str": 7,
			"def": 5,
			"agi": 6,
			"magic": 2,
			"abilities": [],
			"base_stats": monster_forms["Slime"]["stats"],
		}),
		CharacterData.new({
			"id": "unit7",
			"name": "Unit-7",
			"race": CharacterData.RACE_ROBOT,
			"hp": 24,
			"max_hp": 24,
			"str": 5,
			"def": 4,
			"agi": 5,
			"magic": 0,
			"equipment": [equipment["servo_arm"], equipment["gyro_shell"]],
			"base_stats": {"max_hp": 24, "str": 5, "def": 4, "agi": 5, "magic": 0},
		}),
	]


func create_enemies() -> Array[CharacterData]:
	return [
		CharacterData.new({
			"id": "goblin",
			"name": "Goblin",
			"race": "Enemy",
			"hp": 20,
			"max_hp": 20,
			"str": 8,
			"def": 4,
			"agi": 7,
			"magic": 0,
		}),
		CharacterData.new({
			"id": "beast",
			"name": "Beast",
			"race": "Enemy",
			"hp": 24,
			"max_hp": 24,
			"str": 10,
			"def": 5,
			"agi": 6,
			"magic": 0,
		}),
		CharacterData.new({
			"id": "wisp",
			"name": "Wisp",
			"race": "Enemy",
			"hp": 18,
			"max_hp": 18,
			"str": 5,
			"def": 3,
			"agi": 10,
			"magic": 9,
			"abilities": [abilities["fire"]],
		}),
	]


func get_enemy_meat_drop(enemy_id: String) -> Dictionary:
	match enemy_id:
		"goblin":
			return {"name": "Goblin Cut", "type": "beast"}
		"beast":
			return {"name": "Beast Meat", "type": "beast"}
		"wisp":
			return {"name": "Wisp Essence", "type": "undead"}
	return {}


func get_esper_learn_pool() -> Array[Dictionary]:
	return [abilities["spark"], abilities["fire"], abilities["heal"]]


func get_monster_transformation(current_form: String, meat_type: String) -> Dictionary:
	var next_form: String = monster_transforms.get(current_form, {}).get(meat_type, "")
	if next_form.is_empty():
		return {}
	var data: Dictionary = monster_forms.get(next_form, {}).duplicate(true)
	data["form"] = next_form
	return data
