extends Node2D

@onready var player = $Player
var pickup_scene = preload("res://scenes/interactables/pickups/Pickup.tscn")

var spawned_food_positions: Array[Vector2] = []

func _ready() -> void:
	randomize()
	_spawn_food_if_needed()


func _spawn_food_if_needed() -> void:
	if not GameState.should_spawn_underground_food:
		return

	spawned_food_positions.clear()

	var total := randi_range(20, 30)

	for i in range(total):
		var pickup = pickup_scene.instantiate()
		var pos = _find_valid_food_position()

		_setup_random_food_pickup(pickup)

		pickup.global_position = pos
		add_child(pickup)

		spawned_food_positions.append(pos)

	GameState.should_spawn_underground_food = false

func _setup_random_food_pickup(pickup) -> void:
	# 80% mushroom, 20% banana
	if randi() % 100 < 80:
		pickup.item_id = "mushroom"
		pickup.icon_id = "mushroom"
		pickup.amount = 1
	else:
		pickup.item_id = "banana"
		pickup.icon_id = "banana"
		pickup.amount = 1

func _find_valid_food_position() -> Vector2:
	var left := -800.0
	var right := 1180.0
	var top := -200.0
	var bottom := 1000.0

	for i in range(50):
		var pos = Vector2(
			randf_range(left, right),
			randf_range(top, bottom)
		)

		if _is_valid_food_position(pos):
			return pos

	return Vector2(300, 300)

func _is_valid_food_position(pos: Vector2) -> bool:
	if pos.distance_to(player.global_position) < 90:
		return false

	for other in spawned_food_positions:
		if pos.distance_to(other) < 55:
			return false

	return true
