extends Control

@onready var background: ColorRect = $Background
@onready var credits_label: Label = $CreditsLabel

var scroll_speed: float = 45.0


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)

	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	background.color = Color.BLACK

	credits_label.text = """
WASTELANDER

Let this be a lesson...
TO THROW AWAY YOUR TRASH!


Created by Gather Game Design Class \n(and some contributions from extra helpers):

Benito
Chelsea
Collin
Cora
Eloise
Esme
Forest
Greyson
Gwen
Jericho
Katana
Kirra
Levi
Lenny
Liam
Luca
Lydia
Noah
Nyomi
Oliver
Pear
Sadie
Sebastian
Silas
Vienna


THE END
"""

	credits_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	credits_label.add_theme_font_size_override("font_size", 32)
	credits_label.modulate = Color.WHITE
	credits_label.size = Vector2(900, 1600)
	credits_label.position = Vector2(
		(get_viewport_rect().size.x - credits_label.size.x) / 2,
		get_viewport_rect().size.y
	)


func _process(delta: float) -> void:
	credits_label.position.y -= scroll_speed * delta

	# Once credits have completely scrolled off screen,
	# return to the title screen.
	if credits_label.position.y + credits_label.size.y < 0:
		get_tree().change_scene_to_file("res://scenes/ui/TitleReveal.tscn")
