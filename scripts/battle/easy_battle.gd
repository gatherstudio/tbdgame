extends Control

# ==================================================
# EASY BATTLE VALUES
# ==================================================

var monster_health: int = 5
var monster_damage: int = 5
var battle_over: bool = false

var enemy_base_position: Vector2
var enemy_float_time: float = 0.0

# ==================================================
# READY
# ==================================================

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)

	_setup_layout()
	_connect_buttons()

	enemy_base_position = Vector2(930, 360)
	$MonsterSprite.position = enemy_base_position

	$BattleText.text = "An Easy Trash Beast appears!"
	_update_ui()

# ==================================================
# PROCESS
# Simple breathing / floating enemy motion
# ==================================================

func _process(delta: float) -> void:
	if battle_over:
		return

	enemy_float_time += delta
	$MonsterSprite.position.y = enemy_base_position.y + sin(enemy_float_time * 2.2) * 4.0

# ==================================================
# LAYOUT
# ==================================================

func _setup_layout() -> void:
	# Root full screen
	set_anchors_preset(Control.PRESET_FULL_RECT)

	# Background
	$Background.set_anchors_preset(Control.PRESET_FULL_RECT)
	$Background.color = Color(0, 0, 0, 1)

	# Main panel
	$BattlePanel.position = Vector2(110, 90)
	$BattlePanel.size = Vector2(1060, 540)
	$BattlePanel.color = Color(0.10, 0.10, 0.10, 1)

	# Ground line under monster
	$GroundLine.position = Vector2(770, 430)
	$GroundLine.size = Vector2(240, 6)
	$GroundLine.color = Color(0.28, 0.28, 0.28, 1)

	# Player HP
	$PlayerHealthLabel.position = Vector2(145, 130)
	$PlayerHealthLabel.size = Vector2(320, 40)
	$PlayerHealthLabel.add_theme_font_size_override("font_size", 28)
	$PlayerHealthLabel.modulate = Color.WHITE

	# Monster HP
	$MonsterHealthLabel.position = Vector2(825, 130)
	$MonsterHealthLabel.size = Vector2(280, 40)
	$MonsterHealthLabel.add_theme_font_size_override("font_size", 28)
	$MonsterHealthLabel.modulate = Color.WHITE

	# Monster sprite
	$MonsterSprite.position = Vector2(930, 360)
	$MonsterSprite.scale = Vector2(8, 8)

	# Battle text
	$BattleText.position = Vector2(145, 355)
	$BattleText.size = Vector2(520, 120)
	$BattleText.add_theme_font_size_override("font_size", 25)
	$BattleText.modulate = Color.WHITE
	$BattleText.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

	# Attack button
	$AttackButton.position = Vector2(145, 505)
	$AttackButton.size = Vector2(180, 62)
	$AttackButton.modulate = Color(0.95, 0.95, 0.95, 1)

	# Mushroom button
	$MushroomButton.position = Vector2(350, 505)
	$MushroomButton.size = Vector2(180, 62)
	$MushroomButton.modulate = Color(0.85, 1.0, 0.85, 1)

	# Banana button
	$BananaButton.position = Vector2(555, 505)
	$BananaButton.size = Vector2(180, 62)
	$BananaButton.modulate = Color(1.0, 0.97, 0.78, 1)

# ==================================================
# BUTTONS
# ==================================================

func _connect_buttons() -> void:
	$AttackButton.pressed.connect(_on_attack_pressed)
	$MushroomButton.pressed.connect(_on_mushroom_pressed)
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

	$AttackButton.disabled = battle_over
	$MushroomButton.disabled = battle_over or GameState.get_item_count("mushroom") <= 0
	$BananaButton.disabled = battle_over or GameState.get_item_count("banana") <= 0

func _set_action_buttons_enabled(enabled: bool) -> void:
	$AttackButton.disabled = not enabled or battle_over
	$MushroomButton.disabled = not enabled or battle_over or GameState.get_item_count("mushroom") <= 0
	$BananaButton.disabled = not enabled or battle_over or GameState.get_item_count("banana") <= 0

# ==================================================
# PLAYER ACTIONS
# ==================================================

func _on_attack_pressed() -> void:
	if battle_over:
		return

	_set_action_buttons_enabled(false)

	monster_health -= GameState.attack_power
	$BattleText.text = "You attack with %s for %d damage!" % [
		GameState.weapon_name,
		GameState.attack_power
	]

	_flash_monster()
	_update_ui()

	if monster_health <= 0:
		monster_health = 0
		_update_ui()
		await get_tree().create_timer(0.35).timeout
		_player_wins()
		return

	await get_tree().create_timer(0.55).timeout
	await _monster_turn()

	if not battle_over:
		_set_action_buttons_enabled(true)

func _on_mushroom_pressed() -> void:
	if battle_over:
		return

	if not GameState.use_item("mushroom"):
		$BattleText.text = "No mushrooms left!"
		_update_ui()
		return

	$BattleText.text = "You used a mushroom and healed 2 HP!"
	_update_ui()

	# Mushroom does NOT consume your turn
	# No monster attack here

func _on_banana_pressed() -> void:
	if battle_over:
		return

	if not GameState.use_item("banana"):
		$BattleText.text = "No bananas left!"
		_update_ui()
		return

	_set_action_buttons_enabled(false)

	$BattleText.text = "You used a banana and healed to full HP!"
	_update_ui()

	await get_tree().create_timer(0.55).timeout

	if monster_health > 0:
		await _monster_turn()

	if not battle_over:
		_set_action_buttons_enabled(true)

# ==================================================
# MONSTER TURN
# ==================================================

func _monster_turn() -> void:
	if battle_over:
		return

	GameState.take_damage(monster_damage)
	$BattleText.text += "\nThe Easy Trash Beast hits you for %d damage!" % monster_damage
	_update_ui()

	if GameState.is_dead():
		_player_loses()

# ==================================================
# WIN / LOSE
# ==================================================

func _player_wins() -> void:
	battle_over = true
	GameState.set_battle_result("win")

	var reward_text := "You defeated the Easy Trash Beast!"
	GameState.add_item("brains", 1)
	reward_text += "\n+1 Brain"

	if not GameState.easy_level_shards_claimed:
		GameState.add_item("portal_shard", 3)
		GameState.easy_level_shards_claimed = true
		reward_text += "\n+3 Portal Shards!"

	$BattleText.text = reward_text
	_update_ui()

	await get_tree().create_timer(1.4).timeout
	get_tree().change_scene_to_file(GameState.return_scene_path)

func _player_loses() -> void:
	battle_over = true
	GameState.set_battle_result("lose")
	$BattleText.text = "You lost the battle!"
	_update_ui()

	await get_tree().create_timer(1.0).timeout
	GameState.respawn_player()
	get_tree().change_scene_to_file(GameState.return_scene_path)

# ==================================================
# HIT FLASH
# ==================================================

func _flash_monster() -> void:
	$MonsterSprite.modulate = Color(1.0, 0.55, 0.55, 1.0)
	await get_tree().create_timer(0.12).timeout
	$MonsterSprite.modulate = Color(1, 1, 1, 1)
