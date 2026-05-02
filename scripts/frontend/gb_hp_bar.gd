extends Control
class_name GbHpBar

var ratio: float = 1.0
var bg_color := Color("A0C0A0")
var fill_color := Color("203820")


func _ready() -> void:
	custom_minimum_size = Vector2(16, 4)


func setup(new_ratio: float, width: float = 16.0, height: float = 4.0) -> void:
	ratio = clampf(new_ratio, 0.0, 1.0)
	custom_minimum_size = Vector2(width, height)
	queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), bg_color)
	var fill_width: float = floor(size.x * ratio)
	if fill_width > 0.0:
		draw_rect(Rect2(0, 0, fill_width, size.y), fill_color)
