extends Area2D

@export var ending_scene_path: String = "res://scenes/ui/EndCredits.tscn"

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var voice_player: AudioStreamPlayer2D = $AudioStreamPlayer2D

var triggered: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)

	if animated_sprite:
		animated_sprite.play()


func _on_body_entered(body: Node) -> void:
	if triggered:
		return

	if not body.is_in_group("player"):
		return

	triggered = true

	if voice_player and voice_player.stream:
		voice_player.play()
		await voice_player.finished

	get_tree().change_scene_to_file(ending_scene_path)
