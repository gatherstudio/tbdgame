extends Area2D

@export var destination_scene_path: String = "res://scenes/world/WorldUnderground.tscn"
@export var auto_enter: bool = true
@export var interact_action: StringName = &"ui_accept"

var _player_in_range: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _process(_delta: float) -> void:
	if not auto_enter and _player_in_range:
		if Input.is_action_just_pressed(interact_action):
			_change_scene()

func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("player"):
		return

	_player_in_range = true

	if auto_enter:
		_change_scene()

func _on_body_exited(body: Node) -> void:
	if not body.is_in_group("player"):
		return

	_player_in_range = false

func _change_scene() -> void:
	if destination_scene_path.strip_edges() == "":
		return

	var fader := get_tree().current_scene.get_node_or_null("ScreenFader")
	if fader != null:
		fader.fade_out_then_change_scene(destination_scene_path)
	else:
		get_tree().change_scene_to_file(destination_scene_path)
