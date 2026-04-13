extends Node2D

@onready var color_rect: ColorRect = $ColorRect
@onready var title_animation = $TitleAnimation
@onready var hold_timer = $HoldTimer
@onready var title_sound = $TitleSound


func _ready() -> void:
	color_rect.visible = true
	color_rect.color = Color(0, 0, 0, 1)

	if title_sound:
		title_sound.play()

	title_animation.play()

	await fade_in()

	hold_timer.wait_time = 2.5
	hold_timer.one_shot = true
	hold_timer.start()


func fade_in() -> void:
	var tween = create_tween()
	tween.tween_property(color_rect, "color", Color(0.902, 0.812, 0.631, 1.0), 0.7)
	await tween.finished


func _on_hold_timer_timeout() -> void:
	get_tree().change_scene_to_file("res://scenes/world/WorldSurface.tscn")
