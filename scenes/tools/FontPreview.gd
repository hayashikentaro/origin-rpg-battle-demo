extends Control

@onready var preview_text: Control = %PreviewText


func _ready() -> void:
	preview_text.set_content(
		"0123456789\n"
		+ "ABCDE abcde\n"
		+ "▶ たたかう\n"
		+ "  じゅつ\n"
		+ "  どうぐ\n"
		+ "  にげる\n"
		+ "アキ HP 603/800\n"
		+ "イカモンスターが あらわれた！"
	)
