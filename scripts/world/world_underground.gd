extends Node2D

# ============================================================
# LEVEL SETTINGS
# Change these in the Inspector for each underground level.
# ============================================================

@export var level_id: String = "easy"
@export var monster_scene: PackedScene = preload("res://scenes/actors/EasyMonster.tscn")
@export var battle_monster_texture: Texture2D

# Turn this ON only for the boss room.
@export var is_boss_level: bool = false

@export var spawn_food: bool = true

# ============================================================
# NODES
# ============================================================

@onready var player = $Player

@onready var spawn_a = $MonsterSpawnA
@onready var spawn_b = $MonsterSpawnB
@onready var spawn_c = $MonsterSpawnC
@onready var spawn_d = $MonsterSpawnD

var pickup_scene = preload("res://scenes/interactables/pickups/Pickup.tscn")


func _ready() -> void:
	randomize()

	_handle_return_from_battle()
	_restore_player_position_if_needed()
	_spawn_monsters()

	if spawn_food:
		_spawn_food()

func _restore_player_position_if_needed() -> void:
	if not GameState.should_restore_player_position:
		return

	player.global_position = GameState.return_player_position
	GameState.should_restore_player_position = false
	
	
func _handle_return_from_battle() -> void:
	if GameState.last_battle_result == "win":
		if GameState.last_battle_monster_id != "":
			var full_monster_id = _make_level_monster_id(GameState.last_battle_monster_id)

			if not GameState.underground_defeated_monsters_this_visit.has(full_monster_id):
				GameState.underground_defeated_monsters_this_visit.append(full_monster_id)

	GameState.clear_battle_result()
	GameState.last_battle_monster_id = ""
	GameState.save_game()


func _spawn_monsters() -> void:
	var monster_spawn_data = []

	if is_boss_level:
		monster_spawn_data.append({"id": "Boss", "marker": spawn_a})
	else:
		monster_spawn_data = [
			{"id": "A", "marker": spawn_a},
			{"id": "B", "marker": spawn_b},
			{"id": "C", "marker": spawn_c},
			{"id": "D", "marker": spawn_d}
		]

	for data in monster_spawn_data:
		var monster_id: String = data["id"]
		var marker: Node2D = data["marker"]

		var full_monster_id = _make_level_monster_id(monster_id)

		if GameState.underground_defeated_monsters_this_visit.has(full_monster_id):
			continue

		var monster = monster_scene.instantiate()
		monster.global_position = marker.global_position

		# Works for both EasyMonster.gd and BattleMonster.gd
		if "monster_id" in monster:
			monster.monster_id = monster_id

		# Only BattleMonster.gd has battle_texture.
		# This lets each underground level choose the battle image in the Inspector.
		if "battle_texture" in monster:
			monster.battle_texture = battle_monster_texture

		add_child(monster)


func _spawn_food() -> void:
	var food_spawn_points = {
		"FoodSpawnA": $FoodSpawnA,
		"FoodSpawnA2": $FoodSpawnA2,
		"FoodSpawnA3": $FoodSpawnA3,
		"FoodSpawnA4": $FoodSpawnA4,
		"FoodSpawnA5": $FoodSpawnA5,
		"FoodSpawnA6": $FoodSpawnA6,
		"FoodSpawnA7": $FoodSpawnA7,
		"FoodSpawnA8": $FoodSpawnA8,

		"FoodSpawnB": $FoodSpawnB,
		"FoodSpawnB2": $FoodSpawnB2,
		"FoodSpawnB3": $FoodSpawnB3,
		"FoodSpawnB4": $FoodSpawnB4,
		"FoodSpawnB5": $FoodSpawnB5,
		"FoodSpawnB6": $FoodSpawnB6,
		"FoodSpawnB7": $FoodSpawnB7,
		"FoodSpawnB8": $FoodSpawnB8,

		"FoodSpawnC": $FoodSpawnC,
		"FoodSpawnC2": $FoodSpawnC2,
		"FoodSpawnC3": $FoodSpawnC3,
		"FoodSpawnC4": $FoodSpawnC4,
		"FoodSpawnC5": $FoodSpawnC5,
		"FoodSpawnC6": $FoodSpawnC6,
		"FoodSpawnC7": $FoodSpawnC7,
		"FoodSpawnC8": $FoodSpawnC8
	}

	for spawn_id in food_spawn_points.keys():
		var full_food_id = _make_level_food_id(spawn_id)

		if GameState.underground_collected_food_this_visit.has(full_food_id):
			continue

		var marker = food_spawn_points[spawn_id]

		var pickup = pickup_scene.instantiate()
		_setup_random_food_pickup(pickup)

		pickup.spawn_id = full_food_id
		pickup.global_position = marker.global_position

		add_child(pickup)


func _setup_random_food_pickup(pickup) -> void:
	if randi() % 100 < 80:
		pickup.item_id = "mushroom"
		pickup.icon_id = "mushroom"
		pickup.amount = 1
	else:
		pickup.item_id = "banana"
		pickup.icon_id = "banana"
		pickup.amount = 1


func _make_level_monster_id(monster_id: String) -> String:
	return "%s_%s" % [level_id, monster_id]


func _make_level_food_id(food_id: String) -> String:
	return "%s_%s" % [level_id, food_id]
