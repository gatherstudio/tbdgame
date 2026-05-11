extends CharacterBody2D

@export var monster_id: String = ""
@export var battle_texture: Texture2D
@export var monster_name: String = "Medium Trash Beast"
@export var monster_level: int = 2
@export var monster_max_health: int = 15
@export var monster_damage: int = 10
@export var monster_crit_chance: float = 0.10

@export var drop_item: String = "brains"
@export var drop_amount: int = 2

@export var bonus_mushroom_amount: int = 0
@export var bonus_banana_amount: int = 0
@export var bonus_screws_amount: int = 0
@export var bonus_cans_amount: int = 0

@export var battle_scene_path: String = "res://scenes/battle/TrashBeastBattle.tscn"
@export var return_scene_path: String = "res://scenes/world/WorldUndergroundMedium.tscn"

@export var is_boss: bool = false
@export var boss_true_health: int = 100
@export var boss_fake_health: int = 2000

@export var move_distance: float = 32.0
@export var move_speed: float = 40.0

var start_position: Vector2
var points: Array[Vector2] = []
var current_point_index: int = 0
var battle_started: bool = false

@onready var near_sound_zone: Area2D = $NearSoundZone
@onready var monster_near_sound: AudioStreamPlayer2D = $MonsterNearSound


func _ready() -> void:
	start_position = global_position

	points = [
		start_position + Vector2(move_distance, 0),
		start_position + Vector2(move_distance, move_distance),
		start_position + Vector2(0, move_distance),
		start_position
	]

	$Hitbox.body_entered.connect(_on_hitbox_body_entered)
	near_sound_zone.body_entered.connect(_on_near_sound_zone_body_entered)


func _physics_process(_delta: float) -> void:
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


func _on_near_sound_zone_body_entered(body: Node) -> void:
	if battle_started:
		return

	if not body.is_in_group("player"):
		return

	if not monster_near_sound.playing:
		monster_near_sound.play()


func _on_hitbox_body_entered(body: Node) -> void:
	if battle_started:
		return

	if not body.is_in_group("player"):
		return

	GameState.current_battle_bonus_mushroom_amount = bonus_mushroom_amount
	GameState.current_battle_bonus_banana_amount = bonus_banana_amount
	GameState.current_battle_bonus_screws_amount = bonus_screws_amount
	GameState.current_battle_bonus_cans_amount = bonus_cans_amount
	battle_started = true

	GameState.last_battle_monster_id = monster_id
	GameState.return_scene_path = return_scene_path

	GameState.current_battle_monster_name = monster_name
	GameState.current_battle_monster_level = monster_level
	GameState.current_battle_monster_max_health = monster_max_health
	GameState.current_battle_monster_damage = monster_damage
	GameState.current_battle_monster_crit_chance = monster_crit_chance

	GameState.current_battle_drop_item = drop_item
	GameState.current_battle_drop_amount = drop_amount

	GameState.current_battle_is_boss = is_boss
	GameState.current_battle_boss_true_health = boss_true_health
	GameState.current_battle_boss_fake_health = boss_fake_health

	GameState.current_battle_player_goes_first = true
	GameState.current_battle_monster_texture = battle_texture
	GameState.return_player_position = body.global_position
	GameState.should_restore_player_position = true
	get_tree().change_scene_to_file(battle_scene_path)
