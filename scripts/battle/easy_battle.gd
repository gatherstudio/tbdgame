extends Control

var monster_health: int = 5
var monster_damage: int = 5
var battle_over: bool = false
var turn_in_progress: bool = false

var enemy_base_position: Vector2 = Vector2(930, 360)
var enemy_float_time: float = 0.0


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	randomize()

	_setup_layout()
	_connect_buttons()

	$MonsterSprite.position = enemy_base_position
	$BattleText.text = "An Easy Trash Beast appears!"
	_update_ui()


func _process(delta: float) -> void:
	if battle_over:
		return

	enemy_float_time += delta
	$MonsterSprite.position.y = enemy_base_position.y + sin(enemy_float_time * 2.2) * 4.0


func _setup_layout() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)

	$Background.set_anchors_preset(Control.PRESET_FULL_RECT)
	$Background.offset_left = 0
	$Background.offset_top = 0
	$Background.offset_right = 0
	$Background.offset_bottom = 0
	$Background.color = Color.BLACK

	$BattlePanel.position = Vector2(110, 90)
	$BattlePanel.size = Vector2(1060, 540)
	$BattlePanel.color = Color(0.10, 0.10, 0.10, 1)

	$GroundLine.position = Vector2(770, 430)
	$GroundLine.size = Vector2(240, 6)
	$GroundLine.color = Color(0.28, 0.28, 0.28, 1)

	$PlayerHealthLabel.position = Vector2(145, 130)
	$PlayerHealthLabel.size = Vector2(320, 40)
	$PlayerHealthLabel.add_theme_font_size_override("font_size", 28)
	$PlayerHealthLabel.modulate = Color.WHITE

	$MonsterHealthLabel.position = Vector2(825, 130)
	$MonsterHealthLabel.size = Vector2(280, 40)
	$MonsterHealthLabel.add_theme_font_size_override("font_size", 28)
	$MonsterHealthLabel.modulate = Color.WHITE

	$MonsterSprite.position = enemy_base_position
	$MonsterSprite.scale = Vector2(8, 8)

	$BattleText.position = Vector2(145, 355)
	$BattleText.size = Vector2(560, 120)
	$BattleText.add_theme_font_size_override("font_size", 25)
	$BattleText.modulate = Color.WHITE
	$BattleText.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

	$AttackButton.position = Vector2(145, 505)
	$AttackButton.size = Vector2(180, 62)
	$AttackButton.modulate = Color(0.95, 0.95, 0.95, 1)

	$MushroomButton.position = Vector2(350, 505)
	$MushroomButton.size = Vector2(180, 62)
	$MushroomButton.modulate = Color(0.85, 1.0, 0.85, 1)

	$BananaButton.position = Vector2(555, 505)
	$BananaButton.size = Vector2(180, 62)
	$BananaButton.modulate = Color(1.0, 0.97, 0.78, 1)


func _connect_buttons() -> void:
	if not $AttackButton.pressed.is_connected(_on_attack_pressed):
		$AttackButton.pressed.connect(_on_attack_pressed)

	if not $MushroomButton.pressed.is_connected(_on_mushroom_pressed):
		$MushroomButton.pressed.connect(_on_mushroom_pressed)

	if not $BananaButton.pressed.is_connected(_on_banana_pressed):
		$BananaButton.pressed.connect(_on_banana_pressed)


func _update_ui() -> void:
	$PlayerHealthLabel.text = "Player HP: %d / %d" % [
		GameState.current_health,
		GameState.max_health
	]

	$MonsterHealthLabel.text = "Monster HP: %d" % monster_health

	$AttackButton.text = "Attack"
	$MushroomButton.text = "Mushroom (%d)" % GameState.get_item_count("mushroom")
	$BananaButton.text = "Banana (%d)" % GameState.get_item_count("banana")

	_set_action_buttons_enabled(not battle_over and not turn_in_progress)


func _set_action_buttons_enabled(enabled: bool) -> void:
	$AttackButton.disabled = not enabled or battle_over or turn_in_progress
	$MushroomButton.disabled = not enabled or battle_over or turn_in_progress or GameState.get_item_count("mushroom") <= 0
	$BananaButton.disabled = not enabled or battle_over or turn_in_progress or GameState.get_item_count("banana") <= 0


func _on_attack_pressed() -> void:
	if battle_over or turn_in_progress:
		return

	turn_in_progress = true
	_set_action_buttons_enabled(false)

	var damage := GameState.get_attack_damage()
	monster_health -= damage

	if GameState.attack_was_critical(damage):
		$BattleText.text = "Critical hit! You attack with %s for %d damage!" % [
			GameState.weapon_name,
			damage
		]
	else:
		$BattleText.text = "You attack with %s for %d damage!" % [
			GameState.weapon_name,
			damage
		]

	_flash_monster()

	if monster_health <= 0:
		monster_health = 0

	_update_ui()

	if monster_health <= 0:
		await get_tree().create_timer(0.35).timeout
		_player_wins()
		return

	await get_tree().create_timer(0.55).timeout
	await _monster_turn()

	if not battle_over:
		turn_in_progress = false
		_set_action_buttons_enabled(true)


func _on_mushroom_pressed() -> void:
	if battle_over or turn_in_progress:
		return

	if not GameState.use_item("mushroom"):
		$BattleText.text = "No mushrooms left!"
		_update_ui()
		return

	$BattleText.text = "You used a mushroom and healed 2 HP!"
	_update_ui()

	# Mushroom does NOT consume your turn.


func _on_banana_pressed() -> void:
	if battle_over or turn_in_progress:
		return

	if not GameState.use_item("banana"):
		$BattleText.text = "No bananas left!"
		_update_ui()
		return

	turn_in_progress = true
	_set_action_buttons_enabled(false)

	$BattleText.text = "You used a banana and healed to full HP!"
	_update_ui()

	await get_tree().create_timer(0.55).timeout

	if monster_health > 0:
		await _monster_turn()

	if not battle_over:
		turn_in_progress = false
		_set_action_buttons_enabled(true)


func _monster_turn() -> void:
	if battle_over:
		return

	GameState.take_damage(monster_damage)
	$BattleText.text += "\nThe Easy Trash Beast hits you for %d damage!" % monster_damage
	_update_ui()

	if GameState.is_dead():
		_player_loses()


func _player_wins() -> void:
	battle_over = true
	turn_in_progress = true
	GameState.set_battle_result("win")
	_set_action_buttons_enabled(false)

	var reward_text := "You defeated the Easy Trash Beast!"

	# More generous farming drops for Frying Pan upgrade.
	GameState.add_item("screws", 4)
	GameState.add_item("cans", 2)
	reward_text += "\n+4 Screws"
	reward_text += "\n+2 Cans"

	# Helpful survival drops.
	GameState.add_item("mushroom", 2)
	reward_text += "\n+2 Mushrooms"

	if randi() % 2 == 0:
		GameState.add_item("banana", 1)
		reward_text += "\n+1 Banana"

	# First monster of this level gives portal shards.
	if not GameState.easy_level_shards_claimed:
		GameState.add_item("portal_shard", 3)
		GameState.easy_level_shards_claimed = true
		reward_text += "\n+3 Portal Shards!"

	GameState.save_game()

	$BattleText.text = reward_text
	_update_ui()

	await get_tree().create_timer(1.6).timeout
	get_tree().change_scene_to_file(GameState.return_scene_path)


func _player_loses() -> void:
	battle_over = true
	turn_in_progress = true
	GameState.set_battle_result("lose")
	_set_action_buttons_enabled(false)

	$BattleText.text = "You lost the battle!"
	_update_ui()

	await get_tree().create_timer(1.0).timeout
	GameState.respawn_player()
	get_tree().change_scene_to_file(GameState.return_scene_path)


func _flash_monster() -> void:
	$MonsterSprite.modulate = Color(1.0, 0.55, 0.55, 1.0)
	await get_tree().create_timer(0.12).timeout
	$MonsterSprite.modulate = Color.WHITE
