extends Control

const BattleController = preload("res://scripts/frontend/battle_controller.gd")
const GbSprite = preload("res://scripts/frontend/gb_sprite.gd")

const BG_COLOR := Color("e5dfc3")
const PANEL_BG := Color("f6f3df")
const PANEL_BORDER := Color("24331c")
const TEXT_COLOR := Color("1f2b18")
const HP_BG := Color("b9c39b")
const HP_FILL := Color("32452a")

@onready var enemy_list: HBoxContainer = %EnemyList
@onready var ally_list: VBoxContainer = %AllyList
@onready var summary_label: Label = %SummaryLabel
@onready var prompt_label: Label = %PromptLabel
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
	_apply_gb_theme()
	attack_button.pressed.connect(_on_attack_pressed)
	ability_button.pressed.connect(_on_ability_pressed)
	defend_button.pressed.connect(_on_defend_pressed)
	next_button.pressed.connect(_on_next_pressed)
	eat_meat_button.pressed.connect(_on_eat_meat_pressed)
	ability_list.item_selected.connect(_on_ability_selected)
	_refresh_ui()


func _apply_gb_theme() -> void:
	background.color = BG_COLOR
	_style_panels(self)
	_style_buttons()
	_style_labels(self)
	log_label.fit_content = true
	log_label.scroll_active = true
	log_label.bbcode_enabled = false
	ability_list.fixed_column_width = 0
	ability_list.select_mode = ItemList.SELECT_SINGLE
	ability_list.allow_reselect = true
	ability_list.item_count = 0
	ability_list.custom_minimum_size = Vector2(0, 120)
	var list_style := StyleBoxFlat.new()
	list_style.bg_color = PANEL_BG
	list_style.border_color = PANEL_BORDER
	list_style.set_border_width_all(3)
	list_style.set_corner_radius_all(0)
	list_style.content_margin_left = 10
	list_style.content_margin_top = 10
	list_style.content_margin_right = 10
	list_style.content_margin_bottom = 10
	ability_list.add_theme_stylebox_override("panel", list_style)
	ability_list.add_theme_color_override("font_color", TEXT_COLOR)


func _style_panels(node: Node) -> void:
	for child in node.get_children():
		if child is PanelContainer:
			var style := StyleBoxFlat.new()
			style.bg_color = PANEL_BG
			style.border_color = PANEL_BORDER
			style.set_border_width_all(3)
			style.set_corner_radius_all(0)
			child.add_theme_stylebox_override("panel", style)
		_style_panels(child)


func _style_buttons() -> void:
	for button in [attack_button, ability_button, defend_button, next_button, eat_meat_button]:
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var normal := StyleBoxFlat.new()
		normal.bg_color = PANEL_BG
		normal.border_color = PANEL_BORDER
		normal.set_border_width_all(3)
		normal.content_margin_left = 10
		normal.content_margin_right = 10
		normal.content_margin_top = 6
		normal.content_margin_bottom = 6
		var hover := normal.duplicate()
		hover.bg_color = Color("d2dbb5")
		var pressed := normal.duplicate()
		pressed.bg_color = Color("a8b57f")
		button.add_theme_stylebox_override("normal", normal)
		button.add_theme_stylebox_override("hover", hover)
		button.add_theme_stylebox_override("pressed", pressed)
		button.add_theme_stylebox_override("focus", hover)
		button.add_theme_color_override("font_color", TEXT_COLOR)


func _style_labels(node: Node) -> void:
	for child in node.get_children():
		if child is Label:
			child.add_theme_color_override("font_color", TEXT_COLOR)
		elif child is RichTextLabel:
			child.add_theme_color_override("default_color", TEXT_COLOR)
		_style_labels(child)


func _refresh_ui() -> void:
	_refresh_enemy_stage()
	_refresh_party_status()
	_refresh_log()
	summary_label.text = controller.get_status_summary()
	var actor := controller.get_current_actor()
	var state := controller.get_state()

	match state:
		"command":
			attack_button.visible = not actor.is_empty()
			defend_button.visible = not actor.is_empty()
			ability_button.visible = not actor.is_empty() and controller.can_use_ability(actor)
			next_button.visible = actor.is_empty()
			next_button.text = "次へ"
			eat_meat_button.visible = false
			if not actor.is_empty():
				prompt_label.text = "%s（%s）\nHP %d/%d  力 %d  防 %d  早 %d  魔 %d" % [
					actor.get("name", ""),
					_race_label(actor.get("race", "")),
					actor.get("hp", 0),
					actor.get("maxHp", 0),
					actor.get("str", 0),
					actor.get("def", 0),
					actor.get("agi", 0),
					actor.get("magic", 0),
				]
			else:
				prompt_label.text = "全員の行動が決まりました。"
		"victory_meat":
			attack_button.visible = false
			ability_button.visible = false
			defend_button.visible = false
			next_button.visible = true
			next_button.text = "見送る"
			eat_meat_button.visible = controller.can_eat_meat()
			eat_meat_button.text = controller.get_pending_meat_label()
			prompt_label.text = controller.get_status_summary()
		"victory_done", "defeat", "finished":
			attack_button.visible = false
			ability_button.visible = false
			defend_button.visible = false
			next_button.visible = true
			next_button.text = "次へ"
			eat_meat_button.visible = false
			prompt_label.text = controller.get_status_summary()
	ability_list.visible = false


func _refresh_enemy_stage() -> void:
	for child in enemy_list.get_children():
		child.queue_free()
	for enemy in controller.get_enemy_members():
		enemy_list.add_child(_make_enemy_card(enemy))


func _make_enemy_card(unit: Dictionary) -> Control:
	var box := VBoxContainer.new()
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 6)

	var sprite := GbSprite.new()
	sprite.setup(_sprite_id_for_unit(unit), 8)
	sprite.custom_minimum_size = Vector2(88, 88)
	box.add_child(sprite)

	var name_label := Label.new()
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.text = "%s\nHP %d/%d" % [unit.get("name", ""), unit.get("hp", 0), unit.get("maxHp", 0)]
	name_label.add_theme_color_override("font_color", TEXT_COLOR)
	box.add_child(name_label)
	return box


func _refresh_party_status() -> void:
	for child in ally_list.get_children():
		child.queue_free()
	for ally in controller.get_party_members():
		ally_list.add_child(_make_party_row(ally))


func _make_party_row(unit: Dictionary) -> Control:
	var row := HBoxContainer.new()
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_theme_constant_override("separation", 10)

	var sprite := GbSprite.new()
	sprite.setup(_sprite_id_for_unit(unit), 4)
	sprite.custom_minimum_size = Vector2(52, 52)
	row.add_child(sprite)

	var info := VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info.add_theme_constant_override("separation", 2)

	var top := Label.new()
	top.add_theme_color_override("font_color", TEXT_COLOR)
	top.text = "%s  %s" % [unit.get("name", ""), _race_label(unit.get("race", ""))]
	info.add_child(top)

	var hp_line := Label.new()
	hp_line.add_theme_color_override("font_color", TEXT_COLOR)
	hp_line.text = "HP %d/%d   力 %d  防 %d  早 %d  魔 %d" % [
		unit.get("hp", 0),
		unit.get("maxHp", 0),
		unit.get("str", 0),
		unit.get("def", 0),
		unit.get("agi", 0),
		unit.get("magic", 0),
	]
	info.add_child(hp_line)

	var hp_bar_bg := ColorRect.new()
	hp_bar_bg.color = HP_BG
	hp_bar_bg.custom_minimum_size = Vector2(180, 10)
	var hp_bar_fill := ColorRect.new()
	hp_bar_fill.color = HP_FILL
	var max_hp: float = max(1.0, float(unit.get("maxHp", 1)))
	var ratio: float = clampf(float(unit.get("hp", 0)) / max_hp, 0.0, 1.0)
	hp_bar_fill.custom_minimum_size = Vector2(max(8.0, 180.0 * ratio), 10)
	hp_bar_bg.add_child(hp_bar_fill)
	info.add_child(hp_bar_bg)

	if unit.get("race", "") == "Robot":
		var equipment: Array = unit.get("equipment", [])
		if not equipment.is_empty():
			var gear := Label.new()
			gear.add_theme_color_override("font_color", TEXT_COLOR)
			var names: Array[String] = []
			for item in equipment:
				names.append(str(item.get("name", "")))
			gear.text = "装備: %s" % "、".join(names)
			info.add_child(gear)

	row.add_child(info)
	row.modulate = Color.WHITE if unit.get("isAlive", false) else Color(0.65, 0.65, 0.65)
	return row


func _refresh_log() -> void:
	log_label.clear()
	var logs := controller.get_battle_log()
	var start_index := maxi(0, logs.size() - 5)
	for index in range(start_index, logs.size()):
		log_label.append_text(logs[index] + "\n")
	log_label.scroll_to_line(log_label.get_line_count())


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
		ability_list.add_item("%s（%s）" % [ability.get("name", ""), _ability_kind_label(ability.get("kind", ""))])
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
			return "人間"
		"Esper":
			return "エスパー"
		"Monster":
			return "モンスター"
		"Robot":
			return "メカ"
		"Enemy":
			return "敵"
	return race


func _ability_kind_label(kind: String) -> String:
	match kind:
		"heal":
			return "回復"
		"magic_attack":
			return "能力"
	return kind


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
