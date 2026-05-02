extends Control
class_name GbSprite

var sprite_id: String = ""
var scale_factor: int = 4
var fill_color := Color("2f3f28")
var shadow_color := Color("748c55")
var light_color := Color("d8d1af")

const SPRITES := {
	"Human": [
		"00111100",
		"01111110",
		"00111100",
		"00111100",
		"01111110",
		"00100100",
		"01000010",
		"10000001",
	],
	"Esper": [
		"00100100",
		"01111110",
		"00111100",
		"00111100",
		"01111110",
		"00100100",
		"01011010",
		"10000001",
	],
	"Monster": [
		"00111100",
		"01111110",
		"11111111",
		"11111111",
		"11111111",
		"01111110",
		"01100110",
		"11000011",
	],
	"Robot": [
		"01111110",
		"11111111",
		"11011011",
		"11111111",
		"01111110",
		"01100110",
		"11000011",
		"01000010",
	],
	"Goblin": [
		"00100100",
		"01111110",
		"11111111",
		"01111110",
		"00111100",
		"01100110",
		"11000011",
		"10000001",
	],
	"Beast": [
		"01100011",
		"11111111",
		"11111110",
		"01111100",
		"11111110",
		"11111111",
		"11000110",
		"10000010",
	],
	"Wisp": [
		"00011000",
		"00111100",
		"01111110",
		"01111110",
		"00111100",
		"00111100",
		"01100110",
		"00100100",
	],
	"Shadow": [
		"00000000",
		"00000000",
		"00111100",
		"01111110",
		"01111110",
		"00111100",
		"00000000",
		"00000000",
	],
}

func setup(new_sprite_id: String, new_scale: int = 4) -> void:
	sprite_id = new_sprite_id
	scale_factor = new_scale
	custom_minimum_size = Vector2(8 * scale_factor + 16, 8 * scale_factor + 16)
	queue_redraw()


func _draw() -> void:
	var pattern: Array = SPRITES.get(sprite_id, SPRITES["Shadow"])
	var pixel_size := float(scale_factor)
	var total_width := 8.0 * pixel_size
	var total_height := 8.0 * pixel_size
	var origin := Vector2((size.x - total_width) * 0.5, (size.y - total_height) * 0.5)
	draw_rect(Rect2(origin.x + 4, origin.y + total_height - 2, total_width - 8, 4), shadow_color)
	for y in range(pattern.size()):
		var row: String = pattern[y]
		for x in range(row.length()):
			if row[x] == "1":
				var pixel_rect := Rect2(origin.x + x * pixel_size, origin.y + y * pixel_size, pixel_size, pixel_size)
				draw_rect(pixel_rect, fill_color)
				if y <= 2:
					draw_rect(Rect2(pixel_rect.position, Vector2(pixel_size, max(1.0, pixel_size * 0.25))), light_color)
