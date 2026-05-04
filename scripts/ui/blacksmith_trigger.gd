extends Area2D

var has_entered := false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if has_entered:
		return

	if not body.is_in_group("player"):
		return

	has_entered = true

	GameState.return_scene_path = "res://scenes/world/WorldSurface.tscn"
	get_tree().change_scene_to_file("res://scenes/ui/BlacksmithUI.tscn")
