extends Control
class_name GbBitmapText

@export_file("*.png") var font_sheet_path := "res://assets/fonts/gb_font_8x8.png"
@export_file("*.json") var font_map_path := "res://assets/fonts/gb_font_map.json"
@export_multiline var content := ""
@export var pixel_scale := 4
@export var line_spacing := 0

var _texture: Texture2D
var _font_map: Dictionary = {}
var _glyph_size := 8


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_load_font_data()
	queue_redraw()


func set_content(value: String) -> void:
	content = value
	queue_redraw()


func _load_font_data() -> void:
	var image := Image.new()
	var load_error := image.load(ProjectSettings.globalize_path(font_sheet_path))
	if load_error != OK:
		push_error("Failed to load bitmap font sheet: %s" % font_sheet_path)
		return
	_texture = ImageTexture.create_from_image(image)

	var file := FileAccess.open(ProjectSettings.globalize_path(font_map_path), FileAccess.READ)
	if file == null:
		push_error("Failed to load bitmap font map: %s" % font_map_path)
		return
	var parsed = JSON.parse_string(file.get_as_text())
	file.close()
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("Invalid bitmap font map JSON.")
		return
	_font_map = parsed
	_glyph_size = int(_font_map.get("glyph_size", 8))


func _draw() -> void:
	if _texture == null or _font_map.is_empty():
		return
	var lines := content.split("\n")
	for line_index in range(lines.size()):
		var line: String = lines[line_index]
		for char_index in range(line.length()):
			var ch := line.substr(char_index, 1)
			_draw_char(ch, char_index, line_index)


func _draw_char(ch: String, char_index: int, line_index: int) -> void:
	var chars: Dictionary = _font_map.get("characters", {})
	if not chars.has(ch):
		ch = "□" if chars.has("□") else " "
	if not chars.has(ch):
		return
	var glyph: Dictionary = chars[ch]
	var src := Rect2(float(glyph.get("x", 0)), float(glyph.get("y", 0)), _glyph_size, _glyph_size)
	var dst := Rect2(
		char_index * _glyph_size * pixel_scale,
		line_index * (_glyph_size + line_spacing) * pixel_scale,
		_glyph_size * pixel_scale,
		_glyph_size * pixel_scale
	)
	draw_texture_rect_region(_texture, dst, src)
