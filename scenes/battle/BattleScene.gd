extends Control

const BattleController = preload("res://scripts/frontend/battle_controller.gd")
const GbSprite = preload("res://scripts/frontend/gb_sprite.gd")

const BG_COLOR := Color("E0F8D0")
const LIGHT_COLOR := Color("A0C0A0")
const MID_COLOR := Color("607860")
const DARK_COLOR := Color("203820")

@onready var enemy_list: HBoxContainer = %EnemyList
@onready var ally_list: VBoxContainer = %AllyList
@onready var enemy_info_label: Label = %EnemyInfoLabel
@onready var log_label: RichTextLabel = %LogLabel
@onready var attack_button: Button = %AttackButton
@onready var ability_button: Button = %AbilityButton
@onready var defend_button: Button = %DefendButton
@onready var next_button: Button = %NextButton
@onready var eat_meat_button: Button = %EatMeatButton
@onready var ability_list: ItemList = %AbilityList
@onready var background: ColorRect = $Background

var controller := BattleController.new()


func _ready() -> void:
	_apply_palette()
	attack_button.pressed.connect(_on_attack_pressed)
	ability_button.pressed.connect(_on_ability_pressed)
	defend_button.pressed.connect(_on_defend_pressed)
	next_button.pressed.connect(_on_next_pressed)
	eat_meat_button.pressed.connect(_on_eat_meat_pressed)
	ability_list.item_selected.connect(_on_ability_selected)
	_refresh_ui()


func _apply_palette() -> void:
	background.color = BG_COLOR
	_style_labels(self)
	_style_command_buttons()
	ability_list.add_theme_color_override("font_color", DARK_COLOR)
	ability_list.add_theme_color_override("font_selected_color", BG_COLOR)
	ability_list.add_theme_color_override("guide_color", LIGHT_COLOR)
	ability_list.custom_minimum_size = Vector2(80, 48)


func _style_labels(node: Node) -> void:
	for child in node.get_children():
		if child is Label:
			child.add_theme_color_override("font_color", DARK_COLOR)
			child.add_theme_font_size_override("font_size", 8)
		elif child is RichTextLabel:
			child.add_theme_color_override("default_color", DARK_COLOR)
			child.add_theme_font_size_override("normal_font_size", 8)
		_style_labels(child)


func _style_command_buttons() -> void:
	for button in [attack_button, ability_button, defend_button, next_button, eat_meat_button]:
		button.flat = true
		button.focus_mode = Control.FOCUS_NONE
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.add_theme_color_override("font_color", DARK_COLOR)
		button.add_theme_font_size_override("font_size", 8)
		var normal := StyleBoxEmpty.new()
		var hover := StyleBoxFlat.new()
		hover.bg_color = LIGHT_COLOR
		var pressed := StyleBoxFlat.new()
		pressed.bg_color = MID_COLOR
		button.add_theme_stylebox_override("normal", normal)
		button.add_theme_stylebox_override("hover", hover)
		button.add_theme_stylebox_override("pressed", pressed)
		button.add_theme_stylebox_override("focus", hover)


func _refresh_ui() -> void:
	_refresh_enemy_stage()
	_refresh_party_status()
	_refresh_enemy_info()
	_refresh_log()

	var actor := controller.get_current_actor()
	var state := controller.get_state()
	var prompt := controller.get_status_summary()

	match state:
		"command":
			attack_button.visible = not actor.is_empty()
			defend_button.visible = not actor.is_empty()
			ability_button.visible = not actor.is_empty() and controller.can_use_ability(actor)
			next_button.visible = actor.is_empty()
			next_button.text = "▶ つぎへ"
			eat_meat_button.visible = false
			if not actor.is_empty():
				enemy_info_label.text = "%s\n%s\nHP %d/%d" % [
					actor.get("name", ""),
					_race_label(actor.get("race", "")),
					actor.get("hp", 0),
					actor.get("maxHp", 0),
				]
			else:
				enemy_info_label.text = prompt
		"victory_meat":
			attack_button.visible = false
			ability_button.visible = false
			defend_button.visible = false
			next_button.visible = true
			next_button.text = "▶ みおくる"
			eat_meat_button.visible = controller.can_eat_meat()
			eat_meat_button.text = "▶ %s" % controller.get_pending_meat_label()
			enemy_info_label.text = prompt
		"victory_done", "defeat", "finished":
			attack_button.visible = false
			ability_button.visible = false
			defend_button.visible = false
			next_button.visible = true
			next_button.text = "▶ つぎへ"
			eat_meat_button.visible = false
			enemy_info_label.text = prompt

	ability_list.visible = false


func _refresh_enemy_stage() -> void:
	for child in enemy_list.get_children():
		child.queue_free()
	for enemy in controller.get_enemy_members():
		enemy_list.add_child(_make_enemy_sprite(enemy))


func _make_enemy_sprite(unit: Dictionary) -> Control:
	var box := VBoxContainer.new()
	box.custom_minimum_size = Vector2(40, 32)
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 0)

	var sprite := GbSprite.new()
	sprite.setup(_sprite_id_for_unit(unit), 4)
	sprite.custom_minimum_size = Vector2(32, 32)
	box.add_child(sprite)
	return box


func _refresh_party_status() -> void:
	for child in ally_list.get_children():
		child.queue_free()
	for ally in controller.get_party_members():
		ally_list.add_child(_make_party_row(ally))


func _make_party_row(unit: Dictionary) -> Control:
	var row := HBoxContainer.new()
	row.custom_minimum_size = Vector2(68, 10)
	row.add_theme_constant_override("separation", 4)

	var icon := GbSprite.new()
	icon.setup(_sprite_id_for_unit(unit), 1)
	icon.custom_minimum_size = Vector2(10, 10)
	row.add_child(icon)

	var text_box := VBoxContainer.new()
	text_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_box.add_theme_constant_override("separation", 0)

	var name_label := Label.new()
	name_label.text = "%s" % unit.get("name", "")
	name_label.add_theme_color_override("font_color", DARK_COLOR)
	name_label.add_theme_font_size_override("font_size", 8)
	text_box.add_child(name_label)

	var hp_row := HBoxContainer.new()
	hp_row.add_theme_constant_override("separation", 2)

	var hp_label := Label.new()
	hp_label.text = "%d/%d" % [unit.get("hp", 0), unit.get("maxHp", 0)]
	hp_label.add_theme_color_override("font_color", DARK_COLOR)
	hp_label.add_theme_font_size_override("font_size", 8)
	hp_row.add_child(hp_label)

	var bar_bg := ColorRect.new()
	bar_bg.color = LIGHT_COLOR
	bar_bg.custom_minimum_size = Vector2(24, 6)
	var bar_fill := ColorRect.new()
	bar_fill.color = DARK_COLOR
	var max_hp: float = max(1.0, float(unit.get("maxHp", 1)))
	var ratio: float = clampf(float(unit.get("hp", 0)) / max_hp, 0.0, 1.0)
	bar_fill.custom_minimum_size = Vector2(max(1.0, floor(24.0 * ratio)), 6)
	bar_bg.add_child(bar_fill)
	hp_row.add_child(bar_bg)
	text_box.add_child(hp_row)

	row.add_child(text_box)
	row.modulate = Color.WHITE if unit.get("isAlive", false) else Color(0.7, 0.75, 0.7)
	return row


func _refresh_enemy_info() -> void:
	var first_alive := _first_alive_enemy()
	if first_alive.is_empty():
		return
	var count := 0
	for enemy in controller.get_enemy_members():
		if enemy.get("isAlive", false):
			count += 1
	enemy_info_label.text = "%s\n%d匹\n状態: 正常" % [first_alive.get("name", ""), count]


func _refresh_log() -> void:
	log_label.clear()
	var logs := controller.get_battle_log()
	var start_index := maxi(0, logs.size() - 2)
	for index in range(start_index, logs.size()):
		log_label.append_text(logs[index] + "\n")
	log_label.scroll_to_line(log_label.get_line_count())


func _first_alive_enemy() -> Dictionary:
	for enemy in controller.get_enemy_members():
		if enemy.get("isAlive", false):
			return enemy
	return {}


func _on_attack_pressed() -> void:
	controller.queue_attack()
	_refresh_ui()


func _on_defend_pressed() -> void:
	controller.queue_defend()
	_refresh_ui()


func _on_ability_pressed() -> void:
	var actor := controller.get_current_actor()
	if actor.is_empty():
		return
	ability_list.clear()
	for ability in actor.get("abilities", []):
		ability_list.add_item("%s" % ability.get("name", ""))
	ability_list.visible = true


func _on_ability_selected(index: int) -> void:
	controller.queue_ability(index)
	ability_list.visible = false
	_refresh_ui()


func _on_next_pressed() -> void:
	controller.resolve_next_step()
	_refresh_ui()


func _on_eat_meat_pressed() -> void:
	controller.consume_pending_meat()
	_refresh_ui()


func _race_label(race: String) -> String:
	match race:
		"Human":
			return "にんげん"
		"Esper":
			return "エスパー"
		"Monster":
			return "モンスター"
		"Robot":
			return "メカ"
		"Enemy":
			return "てき"
	return race


func _sprite_id_for_unit(unit: Dictionary) -> String:
	match unit.get("race", ""):
		"Human":
			return "Human"
		"Esper":
			return "Esper"
		"Monster":
			return "Monster"
		"Robot":
			return "Robot"
	if unit.get("id", "") == "goblin":
		return "Goblin"
	if unit.get("id", "") == "beast":
		return "Beast"
	if unit.get("id", "") == "wisp":
		return "Wisp"
	return "Shadow"
