extends RefCounted
class_name DamageCalculator

const CharacterData = preload("res://scripts/domain/character_data.gd")


static func physical_damage(attacker: CharacterData, defender: CharacterData, rng: RandomNumberGenerator) -> int:
	var variance := rng.randi_range(-2, 3)
	var raw := attacker.str - int(defender.def / 2.0) + variance
	return maxi(1, raw)


static func magic_damage(attacker: CharacterData, defender: CharacterData, ability_power: int, rng: RandomNumberGenerator) -> int:
	var variance := rng.randi_range(-1, 2)
	var raw := attacker.magic + ability_power - int(defender.def / 3.0) + variance
	return maxi(1, raw)


static func heal_amount(caster: CharacterData, ability_power: int, rng: RandomNumberGenerator) -> int:
	var variance := rng.randi_range(0, 3)
	return maxi(2, caster.magic + ability_power + variance)
