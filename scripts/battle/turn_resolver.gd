extends RefCounted
class_name TurnResolver

const AbilityData = preload("res://scripts/domain/ability_data.gd")
const BattleUnit = preload("res://scripts/domain/battle_unit.gd")
const CharacterData = preload("res://scripts/domain/character_data.gd")
const DamageCalculator = preload("res://scripts/battle/damage_calculator.gd")


static func resolve_action(action: Dictionary, allies: Array[BattleUnit], enemies: Array[BattleUnit], rng: RandomNumberGenerator) -> Array[String]:
	var logs: Array[String] = []
	var actor: CharacterData = action.get("actor")
	if actor == null or not actor.is_alive:
		return logs

	var action_type: String = action.get("type", "attack")
	match action_type:
		"attack":
			var target := _random_target(enemies if action.get("side") == "ally" else allies, rng)
			if target == null:
				return logs
			var damage := DamageCalculator.physical_damage(actor, target.character, rng)
			target.character.apply_damage(damage)
			logs.append("%s attacks %s for %d damage." % [actor.name, target.character.name, damage])
			if not target.character.is_alive:
				logs.append("%s is defeated." % target.character.name)
		"ability":
			var ability: AbilityData = action.get("ability")
			if ability == null:
				return logs
			if ability.kind == "heal":
				var target := _lowest_hp_target(allies if action.get("side") == "ally" else enemies)
				if target == null:
					return logs
				var healed := DamageCalculator.heal_amount(actor, ability.power, rng)
				target.character.heal(healed)
				logs.append("%s uses %s on %s and restores %d HP." % [actor.name, ability.name, target.character.name, healed])
			else:
				var target := _random_target(enemies if action.get("side") == "ally" else allies, rng)
				if target == null:
					return logs
				var damage := DamageCalculator.magic_damage(actor, target.character, ability.power, rng)
				target.character.apply_damage(damage)
				logs.append("%s casts %s on %s for %d damage." % [actor.name, ability.name, target.character.name, damage])
				if not target.character.is_alive:
					logs.append("%s is defeated." % target.character.name)
		"defend":
			logs.append("%s braces for impact." % actor.name)
	return logs


static func _random_target(units: Array[BattleUnit], rng: RandomNumberGenerator) -> BattleUnit:
	var living: Array[BattleUnit] = []
	for unit in units:
		if unit.is_alive():
			living.append(unit)
	if living.is_empty():
		return null
	return living[rng.randi_range(0, living.size() - 1)]


static func _lowest_hp_target(units: Array[BattleUnit]) -> BattleUnit:
	var candidate: BattleUnit = null
	for unit in units:
		if not unit.is_alive():
			continue
		if candidate == null or unit.character.hp < candidate.character.hp:
			candidate = unit
	return candidate
