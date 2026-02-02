extends CanvasLayer

@onready var fade_rect: ColorRect = $FadeRect

@export var fade_time: float = 0.35

func fade_out() -> void:
	_set_alpha(0.0)
	_tween_alpha(1.0)

func fade_in() -> void:
	_set_alpha(1.0)
	_tween_alpha(0.0)

func fade_out_then_change_scene(scene_path: String) -> void:
	_set_alpha(0.0)
	var t := _tween_alpha(1.0)
	t.finished.connect(func ():
		get_tree().change_scene_to_file(scene_path)
	)

func _set_alpha(a: float) -> void:
	var c := fade_rect.color
	c.a = a
	fade_rect.color = c

func _tween_alpha(target_a: float) -> Tween:
	var t := create_tween()
	t.tween_property(fade_rect, "color:a", target_a, fade_time)
	return t
