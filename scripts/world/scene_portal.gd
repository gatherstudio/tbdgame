extends Area2D

@export var destination_scene_path: String = "res://scenes/world/WorldUnderground.tscn"
@export var auto_enter: bool = true
@export var interact_action: StringName = &"ui_accept"

# Turn this on for portals that enter the underground from another level.
# Leave it off for battle returns.
@export var reset_underground_visit: bool = true

var _player_in_range: bool = false
var _is_changing_scene: bool = false


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
	if _is_changing_scene:
		return

	if destination_scene_path.strip_edges() == "":
		return

	_is_changing_scene = true

	if reset_underground_visit:
		_reset_underground_visit_state()

	var fader := get_tree().current_scene.get_node_or_null("ScreenFader")
	if fader != null:
		fader.fade_out_then_change_scene(destination_scene_path)
	else:
		get_tree().change_scene_to_file(destination_scene_path)


func _reset_underground_visit_state() -> void:
	# Old flags, kept for compatibility with older scripts
	GameState.underground_easy_monster_defeated = false
	GameState.should_spawn_underground_easy_monster = true
	GameState.should_spawn_underground_food = true

	# New visit-based tracking
	GameState.underground_defeated_monsters_this_visit.clear()
	GameState.underground_collected_food_this_visit.clear()
	GameState.last_battle_monster_id = ""
	GameState.clear_battle_result()

	GameState.save_game()
