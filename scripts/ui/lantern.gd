extends AnimatedSprite2D

@export var animation_name: String = "glow"

func _ready() -> void:
	if sprite_frames != null and sprite_frames.has_animation(animation_name):
		play(animation_name)
	else:
		play()
