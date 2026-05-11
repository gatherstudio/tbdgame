extends Node

# ==================================================
# SAVE FILE
# ==================================================

const SAVE_PATH := "user://savegame.json"

# ==================================================
# PLAYER IDENTITY
# ==================================================

var player_name: String = "Player"

# ==================================================
# HEALTH / STATS
# ==================================================

var max_health: int = 15
var current_health: int = 15

var weapon_level: int = 1
var weapon_name: String = "Spatula"
var attack_power: int = 1
var armor_level: int = 0

var critical_chance: float = 0.0
var critical_multiplier: int = 2

var return_player_position: Vector2 = Vector2.ZERO
var should_restore_player_position: bool = false
# ==================================================
# CORE INVENTORY
# ==================================================

var should_spawn_underground_food: bool = true

var inventory: Dictionary = {
	"banana": 0,
	"mushroom": 0,
	"screws": 0,
	"cans": 0,
	"sea_glass": 0,
	"portal_shard": 0,
	"brains": 0
}

# ==================================================
# BATTLE / SCENE STATE
# ==================================================

var return_scene_path: String = ""
var last_battle_result: String = ""
var last_battle_monster_id: String = ""
var current_battle_monster_texture: Texture2D = null
var underground_easy_monster_defeated: bool = false
var should_spawn_underground_easy_monster: bool = true
var easy_level_shards_claimed: bool = false

var underground_defeated_monsters_this_visit = []
var underground_collected_food_this_visit = []

var stealth_points: int = 0

var current_battle_monster_name: String = "Trash Beast"
var current_battle_monster_level: int = 1
var current_battle_monster_max_health: int = 5
var current_battle_monster_damage: int = 5
var current_battle_monster_crit_chance: float = 0.0

var current_battle_drop_item: String = "brains"
var current_battle_drop_amount: int = 1

var current_battle_player_goes_first: bool = true

var current_battle_is_boss: bool = false
var current_battle_boss_true_health: int = 100
var current_battle_boss_fake_health: int = 2000

var current_battle_bonus_mushroom_amount: int = 0
var current_battle_bonus_banana_amount: int = 0
var current_battle_bonus_screws_amount: int = 0
var current_battle_bonus_cans_amount: int = 0

# ==================================================
# INVENTORY FUNCTIONS
# ==================================================

func add_item(item_id: String, amount: int = 1) -> void:
	if not inventory.has(item_id):
		inventory[item_id] = 0

	inventory[item_id] += amount


func remove_item(item_id: String, amount: int = 1) -> bool:
	if not inventory.has(item_id):
		return false

	if inventory[item_id] < amount:
		return false

	inventory[item_id] -= amount
	return true


func get_item_count(item_id: String) -> int:
	if not inventory.has(item_id):
		return 0

	return inventory[item_id]


func has_item(item_id: String, amount: int = 1) -> bool:
	return get_item_count(item_id) >= amount

# ==================================================
# SAVE / LOAD
# ==================================================

func save_game() -> void:
	var save_data := {
		"player_name": player_name,
		"max_health": max_health,
		"current_health": current_health,
		"weapon_level": weapon_level,
		"weapon_name": weapon_name,
		"attack_power": attack_power,
		"armor_level": armor_level,
		"critical_chance": critical_chance,
		"critical_multiplier": critical_multiplier,
		"inventory": inventory,
		"easy_level_shards_claimed": easy_level_shards_claimed,
		"underground_defeated_monsters_this_visit": underground_defeated_monsters_this_visit,
		"underground_collected_food_this_visit": underground_collected_food_this_visit
	}

	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		print("Save skipped: could not open save file.")
		return

	file.store_string(JSON.stringify(save_data))
	file.close()


func load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		print("No save file found. Starting fresh.")
		return

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		print("Load skipped: could not open save file.")
		return

	var text := file.get_as_text()
	file.close()

	var save_data = JSON.parse_string(text)
	if save_data == null:
		print("Load skipped: save file was not readable.")
		return

	player_name = str(save_data.get("player_name", "Player"))

	max_health = int(save_data.get("max_health", 15))
	current_health = int(save_data.get("current_health", max_health))

	weapon_level = int(save_data.get("weapon_level", 1))
	weapon_name = str(save_data.get("weapon_name", "Spatula"))
	attack_power = int(save_data.get("attack_power", 1))
	armor_level = int(save_data.get("armor_level", 0))
	critical_chance = float(save_data.get("critical_chance", 0.0))
	critical_multiplier = int(save_data.get("critical_multiplier", 2))

	inventory = save_data.get("inventory", {
		"banana": 0,
		"mushroom": 0,
		"screws": 0,
		"cans": 0,
		"sea_glass": 0,
		"portal_shard": 0,
		"brains": 0
	})

	easy_level_shards_claimed = bool(save_data.get("easy_level_shards_claimed", false))

	underground_defeated_monsters_this_visit = save_data.get("underground_defeated_monsters_this_visit", [])
	underground_collected_food_this_visit = save_data.get("underground_collected_food_this_visit", [])


func has_save_file() -> bool:
	return FileAccess.file_exists(SAVE_PATH)


func delete_save_file() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)


func start_new_game() -> void:
	delete_save_file()
	reset_all()
	save_game()

# ==================================================
# FULL RESET
# ==================================================

func reset_all() -> void:
	player_name = "Player"

	max_health = 15
	current_health = 15

	weapon_level = 1
	weapon_name = "Spatula"
	attack_power = 1
	armor_level = 0
	critical_chance = 0.0
	critical_multiplier = 2

	inventory = {
		"banana": 0,
		"mushroom": 0,
		"screws": 0,
		"cans": 0,
		"sea_glass": 0,
		"portal_shard": 0,
		"brains": 0
	}

	return_scene_path = ""
	last_battle_result = ""
	last_battle_monster_id = ""

	underground_easy_monster_defeated = false
	should_spawn_underground_easy_monster = true
	easy_level_shards_claimed = false
	should_spawn_underground_food = true

	underground_defeated_monsters_this_visit.clear()
	underground_collected_food_this_visit.clear()

# ==================================================
# HEALTH FUNCTIONS
# ==================================================

func heal(amount: int) -> void:
	current_health = min(current_health + amount, max_health)
	save_game()


func heal_full() -> void:
	current_health = max_health
	save_game()


func take_damage(amount: int) -> void:
	current_health = max(current_health - amount, 0)


func is_dead() -> bool:
	return current_health <= 0


func set_max_health(value: int) -> void:
	max_health = value
	current_health = min(current_health, max_health)

# ==================================================
# RESPAWN / BATTLE HELPERS
# ==================================================

func respawn_player() -> void:
	current_health = max_health
	save_game()


func set_battle_result(result: String) -> void:
	last_battle_result = result


func clear_battle_result() -> void:
	last_battle_result = ""

# ==================================================
# ITEM USE
# ==================================================

func use_item(item_id: String) -> bool:
	if not has_item(item_id, 1):
		return false

	match item_id:
		"mushroom":
			current_health = min(current_health + 2, max_health)
			remove_item(item_id, 1)
			save_game()
			return true

		"banana":
			current_health = max_health
			remove_item(item_id, 1)
			save_game()
			return true

		_:
			return false

# ==================================================
# HELPER GETTERS
# ==================================================

func get_portal_shards() -> int:
	return get_item_count("portal_shard")


func get_screws() -> int:
	return get_item_count("screws")


func get_cans() -> int:
	return get_item_count("cans")


func get_brains() -> int:
	return get_item_count("brains")


func get_sea_glass() -> int:
	return get_item_count("sea_glass")

# ==================================================
# ATTACK / CRITICAL HIT LOGIC
# ==================================================

func get_attack_damage() -> int:
	if critical_chance > 0.0:
		if randf() < critical_chance:
			return attack_power * critical_multiplier

	return attack_power


func attack_was_critical(damage: int) -> bool:
	return damage > attack_power

# ==================================================
# WEAPON UPGRADE REQUIREMENTS
# ==================================================

func can_upgrade_to_frying_pan() -> bool:
	return has_item("screws", 10) and has_item("cans", 3)


func can_upgrade_to_spiky_pan() -> bool:
	return has_item("screws", 15) and has_item("cans", 3)


func can_upgrade_to_final_weapon() -> bool:
	return has_item("screws", 20) and has_item("cans", 5) and has_item("sea_glass", 3)


func upgrade_weapon() -> bool:
	match weapon_level:
		1:
			if not can_upgrade_to_frying_pan():
				return false

			remove_item("screws", 10)
			remove_item("cans", 3)

			weapon_level = 2
			weapon_name = "Frying Pan"
			attack_power = 3
			armor_level = 1
			critical_chance = 0.0

			set_max_health(20)
			current_health = max_health
			save_game()

			return true

		2:
			if not can_upgrade_to_spiky_pan():
				return false

			remove_item("screws", 15)
			remove_item("cans", 3)

			weapon_level = 3
			weapon_name = "Spiky Frying Pan"
			attack_power = 5
			armor_level = 2
			critical_chance = 0.0

			set_max_health(25)
			current_health = max_health
			save_game()

			return true

		3:
			if not can_upgrade_to_final_weapon():
				return false

			remove_item("screws", 20)
			remove_item("cans", 5)
			remove_item("sea_glass", 3)

			weapon_level = 4
			weapon_name = "Mystery Final Weapon"
			attack_power = 10
			armor_level = 3
			critical_chance = 0.20
			critical_multiplier = 2

			set_max_health(30)
			current_health = max_health
			save_game()

			return true

		_:
			return false


func get_next_upgrade_text() -> String:
	match weapon_level:
		1:
			return "Frying Pan\nCost: 10 Screws + 3 Cans\nAttack: 3"

		2:
			return "Spiky Frying Pan\nCost: 15 Screws + 3 Cans\nAttack: 5"

		3:
			return "Mystery Final Weapon\nCost: 20 Screws + 5 Cans + 3 Sea Glass\nAttack: 10\n20% chance for critical hit"

		_:
			return "Weapon fully upgraded."
