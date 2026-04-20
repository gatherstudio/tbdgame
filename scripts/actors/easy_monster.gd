extends CharacterBody2D

@export var move_distance: float = 32.0
@export var move_speed: float = 40.0

var start_position: Vector2
var points: Array[Vector2] = []
var current_point_index: int = 0
var battle_started: bool = false

func _ready() -> void:
	start_position = global_position

	points = [
		start_position + Vector2(move_distance, 0),
		start_position + Vector2(move_distance, move_distance),
		start_position + Vector2(0, move_distance),
		start_position
	]

	$Hitbox.body_entered.connect(_on_hitbox_body_entered)

func _physics_process(delta: float) -> void:
	if battle_started:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var target: Vector2 = points[current_point_index]
	var distance := global_position.distance_to(target)

	if distance < 2.0:
		current_point_index = (current_point_index + 1) % points.size()
		velocity = Vector2.ZERO
	else:
		var direction := global_position.direction_to(target)
		velocity = direction * move_speed

	move_and_slide()

func _on_hitbox_body_entered(body: Node) -> void:
	if battle_started:
		return

	if body.name == "Player":
		battle_started = true
		GameState.return_scene_path = "res://scenes/world/WorldUnderground.tscn"
		get_tree().change_scene_to_file("res://scenes/battle/EasyBattle.tscn")
