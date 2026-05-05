extends Control

const BattleController = preload("res://scripts/frontend/battle_controller.gd")
const GbHpBar = preload("res://scripts/frontend/gb_hp_bar.gd")
const GbSprite = preload("res://scripts/frontend/gb_sprite.gd")

const INTERNAL_SIZE := Vector2(160, 144)
const DISPLAY_SCALE := 8.0
const BG_COLOR := Color("E0F8D0")
const LIGHT_COLOR := Color("A0C0A0")
const MID_COLOR := Color("607860")
const DARK_COLOR := Color("203820")
const MONACO_FONT_PATH := "/System/Library/Fonts/Monaco.ttf"

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
var _command_previews: Array = []


func _ready() -> void:
	custom_minimum_size = INTERNAL_SIZE
	set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	size = INTERNAL_SIZE
	scale = Vector2(DISPLAY_SCALE, DISPLAY_SCALE)
	_layout_root()
	_apply_palette()
	attack_button.pressed.connect(_on_attack_pressed)
	ability_button.pressed.connect(_on_ability_pressed)
	defend_button.pressed.connect(_on_defend_pressed)
	next_button.pressed.connect(_on_next_pressed)
	eat_meat_button.pressed.connect(_on_eat_meat_pressed)
	ability_list.item_selected.connect(_on_ability_selected)
	_refresh_ui()


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_layout_root()


func _layout_root() -> void:
	var viewport_size := get_viewport_rect().size
	var scaled_size := INTERNAL_SIZE * DISPLAY_SCALE
	position = (viewport_size - scaled_size) * 0.5


func _apply_palette() -> void:
	background.color = BG_COLOR
	_apply_pixel_font()
	_style_labels(self)
	_style_command_buttons()
	ability_list.add_theme_color_override("font_color", DARK_COLOR)
	ability_list.add_theme_color_override("font_selected_color", BG_COLOR)
	ability_list.add_theme_color_override("guide_color", LIGHT_COLOR)
	ability_list.custom_minimum_size = Vector2(80, 48)


func _apply_pixel_font() -> void:
	if not FileAccess.file_exists(MONACO_FONT_PATH):
		return
	var font := SystemFont.new()
	font.font_names = PackedStringArray(["Monaco"])
	font.antialiasing = TextServer.FONT_ANTIALIASING_NONE
	font.hinting = TextServer.HINTING_NONE
	font.subpixel_positioning = TextServer.SUBPIXEL_POSITIONING_DISABLED
	font.oversampling = 1.0
	var local_theme := Theme.new()
	local_theme.default_font = font
	local_theme.default_font_size = 6
	theme = local_theme


func _style_labels(node: Node) -> void:
	for child in node.get_children():
		if child is Label:
			child.add_theme_color_override("font_color", DARK_COLOR)
			child.add_theme_font_size_override("font_size", 6)
		elif child is RichTextLabel:
			child.add_theme_color_override("default_color", DARK_COLOR)
			child.add_theme_font_size_override("normal_font_size", 6)
		_style_labels(child)


func _style_command_buttons() -> void:
	for button in [attack_button, ability_button, defend_button, next_button, eat_meat_button]:
		button.flat = true
		button.focus_mode = Control.FOCUS_NONE
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.add_theme_color_override("font_color", DARK_COLOR)
		button.add_theme_font_size_override("font_size", 6)
		button.custom_minimum_size = Vector2(0, 6)
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
	var actor := controller.get_current_actor()
	var state := controller.get_state()
	_command_previews = []
	if state == "command" and not actor.is_empty():
		_command_previews = controller.preview_current_actor_commands()

	_refresh_enemy_stage()
	_refresh_party_status()
	_refresh_enemy_info()
	_refresh_log()
	var prompt := controller.get_status_summary()

	match state:
		"command":
			attack_button.visible = not actor.is_empty()
			defend_button.visible = not actor.is_empty()
			ability_button.visible = not actor.is_empty() and controller.can_use_ability(actor)
			next_button.visible = actor.is_empty()
			next_button.text = "▶つぎへ"
			eat_meat_button.visible = false
		"victory_meat":
			attack_button.visible = false
			ability_button.visible = false
			defend_button.visible = false
			next_button.visible = true
			next_button.text = "▶みおくる"
			eat_meat_button.visible = controller.can_eat_meat()
			eat_meat_button.text = "▶%s" % controller.get_pending_meat_label()
		"victory_done", "defeat", "finished":
			attack_button.visible = false
			ability_button.visible = false
			defend_button.visible = false
			next_button.visible = true
			next_button.text = "▶つぎへ"
			eat_meat_button.visible = false

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
	sprite.setup(_sprite_id_for_unit(unit), 3)
	sprite.custom_minimum_size = Vector2(28, 28)
	box.add_child(sprite)
	return box


func _refresh_party_status() -> void:
	for child in ally_list.get_children():
		child.queue_free()
	for ally in controller.get_party_members():
		ally_list.add_child(_make_party_row(ally))


func _make_party_row(unit: Dictionary) -> Control:
	var row := HBoxContainer.new()
	row.custom_minimum_size = Vector2(68, 8)
	row.add_theme_constant_override("separation", 2)
	row.clip_contents = true

	var icon := GbSprite.new()
	icon.setup(_sprite_id_for_unit(unit), 1)
	icon.custom_minimum_size = Vector2(8, 8)
	row.add_child(icon)

	var name_label := Label.new()
	name_label.text = unit.get("name", "")
	name_label.add_theme_color_override("font_color", DARK_COLOR)
	name_label.add_theme_font_size_override("font_size", 6)
	name_label.custom_minimum_size = Vector2(22, 8)
	row.add_child(name_label)

	var hp_label := Label.new()
	hp_label.text = "%d/%d" % [unit.get("hp", 0), unit.get("maxHp", 0)]
	hp_label.add_theme_color_override("font_color", DARK_COLOR)
	hp_label.add_theme_font_size_override("font_size", 6)
	hp_label.custom_minimum_size = Vector2(20, 8)
	row.add_child(hp_label)

	var max_hp: float = max(1.0, float(unit.get("maxHp", 1)))
	var ratio: float = clampf(float(unit.get("hp", 0)) / max_hp, 0.0, 1.0)
	var hp_bar := GbHpBar.new()
	hp_bar.setup(ratio, 16.0, 4.0)
	row.add_child(hp_bar)
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
	var state := controller.get_state()
	var actor := controller.get_current_actor()
	var lines: Array[String] = []
	lines.append("%s %d匹" % [first_alive.get("name", ""), count])
	lines.append("状態: 正常")
	if state == "command" and not actor.is_empty():
		lines.append("%s %s" % [actor.get("name", ""), _race_label(actor.get("race", ""))])
		lines.append("HP %d/%d" % [actor.get("hp", 0), actor.get("maxHp", 0)])
		if _command_previews.size() > 0:
			lines.append(_format_command_preview_debug(
				str(_command_previews[0].get("label", "ATK")),
				_command_previews[0].get("result", {})
			))
		if _command_previews.size() > 2:
			lines.append(_format_command_preview_debug(
				str(_command_previews[2].get("label", "PTR")),
				_command_previews[2].get("result", {})
			))
	else:
		lines.append(controller.get_status_summary())
	enemy_info_label.text = "\n".join(lines)


func _refresh_log() -> void:
	log_label.clear()
	var logs := controller.get_battle_log()
	var start_index := maxi(0, logs.size() - 1)
	for index in range(start_index, logs.size()):
		log_label.append_text(logs[index] + "\n")
	if ability_list.visible:
		for preview in _command_previews:
			log_label.append_text(_format_log_preview_debug(preview) + "\n")
			for trace_line in _extract_preview_trace(preview):
				log_label.append_text("  %s\n" % trace_line)


func _first_alive_enemy() -> Dictionary:
	for enemy in controller.get_enemy_members():
		if enemy.get("isAlive", false):
			return enemy
	return {}


func _format_actor_resolve_debug(result: Dictionary) -> String:
	if result.is_empty():
		return "DBG --"
	var branch := str(result.get("branch", "--"))
	var post_branch_route := str(result.get("postBranchRoute", "--"))
	var local_path := str(result.get("localPath", "--"))
	var post_branch_target_source := str(result.get("postBranchTargetSource", "--"))
	var pointer_flavor := str(result.get("pointerFlavor", "--"))
	var target := str(result.get("target", "--"))
	var used_candidate_rng := "Y" if bool(result.get("didConsumeCandidateRng", false)) else "N"
	var action: Dictionary = result.get("action", {})
	var kind_id := str(action.get("kindId", "--"))
	var arg := str(action.get("arg", "--"))
	var slot_index := str(action.get("slotIndex", "--"))
	var combat_decision: Dictionary = result.get("combatDecision", {})
	var accepted := "--"
	var decision_branch := "--"
	var decision_variant := "--"
	if combat_decision is Dictionary and combat_decision.has("accepted"):
		accepted = "Y" if bool(combat_decision.get("accepted", false)) else "N"
	decision_branch = str(combat_decision.get("branch", "--"))
	decision_variant = str(combat_decision.get("branchVariant", "--"))
	return "DBG b:%s r:%s p:%s ts:%s pf:%s t:%s\nk:%s a:%s s:%s c07:%s acc:%s cb:%s cv:%s" % [
		branch,
		post_branch_route,
		local_path,
		post_branch_target_source,
		pointer_flavor,
		target,
		kind_id,
		arg,
		slot_index,
		used_candidate_rng,
		accepted,
		decision_branch,
		decision_variant,
	]


func _format_command_preview_debug(label: String, result: Dictionary) -> String:
	if result.is_empty():
		return "%s --" % label
	var branch := str(result.get("branch", "--"))
	var post_branch_route := str(result.get("postBranchRoute", "--"))
	var local_path := str(result.get("localPath", "--"))
	var post_branch_target_source := str(result.get("postBranchTargetSource", "--"))
	var pointer_flavor := str(result.get("pointerFlavor", "--"))
	var target := str(result.get("target", "--"))
	var target_source := str(result.get("targetSource", "--"))
	var used_candidate_rng := "Y" if bool(result.get("didConsumeCandidateRng", false)) else "N"
	var candidate_offset := str(result.get("candidateOffset", "--"))
	var action: Dictionary = result.get("action", {})
	var arg := str(action.get("arg", "--"))
	var combat_decision: Dictionary = result.get("combatDecision", {})
	var accepted := "--"
	var decision_branch := "--"
	var decision_variant := "--"
	var decision_source := "--"
	var decision_meaning := "--"
	if combat_decision is Dictionary and combat_decision.has("accepted"):
		accepted = "Y" if bool(combat_decision.get("accepted", false)) else "N"
	decision_branch = str(combat_decision.get("branch", "--"))
	decision_variant = str(combat_decision.get("branchVariant", "--"))
	decision_source = str(combat_decision.get("debugSource", "--"))
	decision_meaning = str(combat_decision.get("pendingMeaning", "--"))
	return "%s b:%s r:%s p:%s src:%s ptr:%s a:%s t:%s/%s 07:%s off:%s acc:%s cb:%s cv:%s/%s/%s" % [
		label,
		branch,
		post_branch_route,
		local_path,
		post_branch_target_source,
		pointer_flavor,
		arg,
		target,
		target_source,
		used_candidate_rng,
		candidate_offset,
		accepted,
		decision_branch,
		decision_variant,
		decision_source,
		decision_meaning,
	]


func _format_log_preview_debug(preview: Dictionary) -> String:
	var label := str(preview.get("label", "ABL"))
	var result: Dictionary = preview.get("result", {})
	if result.is_empty():
		return "%s --" % label
	var post_branch_route := str(result.get("postBranchRoute", "--"))
	var local_path := str(result.get("localPath", "--"))
	var post_branch_target_source := str(result.get("postBranchTargetSource", "--"))
	var pointer_flavor := str(result.get("pointerFlavor", "--"))
	var target := str(result.get("target", "--"))
	var target_source := str(result.get("targetSource", "--"))
	var used_candidate_rng := "Y" if bool(result.get("didConsumeCandidateRng", false)) else "N"
	var candidate_offset := str(result.get("candidateOffset", "--"))
	var action: Dictionary = result.get("action", {})
	var kind_id := str(action.get("kindId", "--"))
	var arg := str(action.get("arg", "--"))
	var slot_index := str(action.get("slotIndex", "--"))
	var combat_decision: Dictionary = result.get("combatDecision", {})
	var accepted := str(combat_decision.get("accepted", "--"))
	var decision_branch := str(combat_decision.get("branch", "--"))
	var decision_variant := str(combat_decision.get("branchVariant", "--"))
	var decision_source := str(combat_decision.get("debugSource", "--"))
	var decision_meaning := str(combat_decision.get("pendingMeaning", "--"))
	return "%s k:%s a:%s s:%s r:%s p:%s src:%s ptr:%s t:%s/%s 07:%s off:%s acc:%s cb:%s cv:%s src:%s/%s" % [
		label,
		kind_id,
		arg,
		slot_index,
		post_branch_route,
		local_path,
		post_branch_target_source,
		pointer_flavor,
		target,
		target_source,
		used_candidate_rng,
		candidate_offset,
		accepted,
		decision_branch,
		decision_variant,
		decision_source,
		decision_meaning,
	]


func _extract_preview_trace(preview: Dictionary) -> Array[String]:
	var lines: Array[String] = []
	var result: Dictionary = preview.get("result", {})
	for line in result.get("debugTrace", []):
		lines.append(str(line))
	return lines


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
	_refresh_log()


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
