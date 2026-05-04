extends CharacterBody2D
"""
PLAYER (Point-and-Click, Top-Down)

Click anywhere in the world to move the player to that location.
The Camera2D follows automatically because it is a child of Player.

This version is intentionally simple:
- No pathfinding
- No obstacles yet
- Straight-line movement only
"""

# ============================================================
# STUDENT DEVELOPER ZONE
# Safe to edit values in this section.
# ============================================================

@export var move_speed: float = 150.0

# How close the player must get to the target before stopping
@export var stop_distance: float = 6.0

# Animation names used by PlayerSprite
@export var idle_animation_name: String = "float"
@export var walk_animation_name: String = "walk"

# ============================================================
# CORE LOGIC
# ============================================================

@onready var player_sprite: AnimatedSprite2D = $PlayerSprite

var _destination: Vector2
var _has_destination: bool = false


func _ready() -> void:
	player_sprite.play()
	# Start idle if available
	_play_if_exists(idle_animation_name)


func _unhandled_input(event: InputEvent) -> void:
	# Set destination on mouse click
	if event is InputEventMouseButton and event.pressed:
		var mouse_event := event as InputEventMouseButton

		if mouse_event.button_index == MOUSE_BUTTON_LEFT:
			_set_destination(get_global_mouse_position())


func _physics_process(_delta: float) -> void:

	# 1. Check keyboard input
	var input_vector := Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	)

	# 2. If keyboard is used -> move by keyboard
	if input_vector.length() > 0:
		_has_destination = false
		var direction := input_vector.normalized()
		velocity = direction * move_speed
		move_and_slide()
		_update_animation(direction)
		return

	# 3. Otherwise use click-to-move
	if _has_destination:
		var to_target := _destination - global_position
		var distance := to_target.length()

		if distance <= stop_distance:
			_has_destination = false
			velocity = Vector2.ZERO
			_update_animation(Vector2.ZERO)
			return

		var direction := to_target.normalized()
		velocity = direction * move_speed
		move_and_slide()
		_update_animation(direction)
	else:
		velocity = Vector2.ZERO
		_update_animation(Vector2.ZERO)


func _set_destination(world_position: Vector2) -> void:
	_destination = world_position
	_has_destination = true


func _update_animation(direction: Vector2) -> void:
	if player_sprite == null:
		return

	if direction == Vector2.ZERO:
		_play_if_exists(idle_animation_name)
		return

	_play_if_exists(walk_animation_name)

	# Flip sprite when moving left/right
	if direction.x != 0:
		player_sprite.flip_h = direction.x < 0


func _play_if_exists(animation_name: String) -> void:
	if player_sprite.sprite_frames == null:
		return

	if player_sprite.sprite_frames.has_animation(animation_name):
		if player_sprite.animation != animation_name:
			player_sprite.play(animation_name)
