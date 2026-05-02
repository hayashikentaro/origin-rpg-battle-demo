extends NinePatchRect
class_name GbWindow

const BG := Color("E0F8D0")
const LIGHT := Color("A0C0A0")
const MID := Color("607860")
const DARK := Color("203820")

static var _shared_texture: Texture2D


func _ready() -> void:
	if _shared_texture == null:
		_shared_texture = _build_texture()
	texture = _shared_texture
	patch_margin_left = 8
	patch_margin_top = 8
	patch_margin_right = 8
	patch_margin_bottom = 8
	draw_center = true
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _build_texture() -> Texture2D:
	var image := Image.create(24, 24, false, Image.FORMAT_RGBA8)
	image.fill(BG)

	for x in range(24):
		for y in range(24):
			var border := x == 0 or y == 0 or x == 23 or y == 23
			var inner_border := x == 1 or y == 1 or x == 22 or y == 22
			var shadow_border := x == 2 or y == 2 or x == 21 or y == 21
			if border:
				image.set_pixel(x, y, DARK)
			elif inner_border:
				image.set_pixel(x, y, LIGHT)
			elif shadow_border:
				image.set_pixel(x, y, MID)
			else:
				image.set_pixel(x, y, BG)

	for x in range(3, 21):
		image.set_pixel(x, 3, LIGHT)
		image.set_pixel(3, x, LIGHT)
		image.set_pixel(x, 20, MID)
		image.set_pixel(20, x, MID)

	return ImageTexture.create_from_image(image)
