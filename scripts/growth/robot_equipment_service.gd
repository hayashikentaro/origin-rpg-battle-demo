extends RefCounted
class_name RobotEquipmentService

const CharacterData = preload("res://scripts/domain/character_data.gd")


func apply_equipment_stats(character: CharacterData) -> void:
	if character.race != CharacterData.RACE_ROBOT:
		return

	var total_bonus := {
		"max_hp": 0,
		"str": 0,
		"def": 0,
		"agi": 0,
		"magic": 0,
	}
	for item in character.equipment:
		for stat_key in total_bonus.keys():
			total_bonus[stat_key] += int(item.stat_bonuses.get(stat_key, 0))

	character.equipment_stats = total_bonus
	var combined := character.base_stats.duplicate(true)
	for stat_key in total_bonus.keys():
		combined[stat_key] = int(combined.get(stat_key, 0)) + int(total_bonus.get(stat_key, 0))

	var current_hp_ratio := 1.0
	if character.max_hp > 0:
		current_hp_ratio = float(character.hp) / float(character.max_hp)

	character.set_stats_from_dict(combined)
	character.hp = clampi(int(round(character.max_hp * current_hp_ratio)), 1, character.max_hp)
