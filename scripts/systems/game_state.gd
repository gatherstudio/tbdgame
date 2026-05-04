extends Node

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

# Final weapon special ability
var critical_chance: float = 0.0
var critical_multiplier: int = 2

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
var last_battle_result: String = ""   # "win", "lose", or ""

var underground_easy_monster_defeated: bool = false
var should_spawn_underground_easy_monster: bool = true
var easy_level_shards_claimed: bool = false

# ==================================================
# CORE INVENTORY FUNCTIONS
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
# FULL RESET
# Use only for new game / hard reset
# NOT for normal battle loss
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

	underground_easy_monster_defeated = false
	should_spawn_underground_easy_monster = true
	easy_level_shards_claimed = false
	should_spawn_underground_food = true

# ==================================================
# HEALTH FUNCTIONS
# ==================================================

func heal(amount: int) -> void:
	current_health = min(current_health + amount, max_health)


func heal_full() -> void:
	current_health = max_health


func take_damage(amount: int) -> void:
	current_health = max(current_health - amount, 0)


func is_dead() -> bool:
	return current_health <= 0


func set_max_health(value: int) -> void:
	max_health = value
	current_health = min(current_health, max_health)

# ==================================================
# RESPAWN / BATTLE HELPERS
# Use this after losing a normal battle
# Keeps inventory, upgrades, etc.
# ==================================================

func respawn_player() -> void:
	current_health = max_health


func set_battle_result(result: String) -> void:
	last_battle_result = result


func clear_battle_result() -> void:
	last_battle_result = ""

# ==================================================
# ITEM USE
# Mushrooms = +2 HP
# Bananas = full heal
# ==================================================

func use_item(item_id: String) -> bool:
	if not has_item(item_id, 1):
		return false

	match item_id:
		"mushroom":
			heal(2)
			remove_item(item_id, 1)
			return true

		"banana":
			heal_full()
			remove_item(item_id, 1)
			return true

		_:
			return false

# ==================================================
# HELPER GETTERS FOR HUD / GAME LOGIC
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
# Final weapon has 20% chance to deal 2x damage
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
# Based on storyteller/dev notes
#
# Spatula = free, 1 ATK
# Frying Pan = 10 screws + 3 cans, 3 ATK
# Spiky Frying Pan = 15 screws + 3 cans, 5 ATK
# Final weapon = 10 ATK, 20% critical chance
# Final cost/name still not finalized in docs
# ==================================================

func can_upgrade_to_frying_pan() -> bool:
	return has_item("screws", 10) and has_item("cans", 3)


func can_upgrade_to_spiky_pan() -> bool:
	return has_item("screws", 15) and has_item("cans", 3)


func can_upgrade_to_final_weapon() -> bool:
	# TODO: Students still need to finalize this cost.
	# This is a placeholder so the system works.
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

			return true

		3:
			if not can_upgrade_to_final_weapon():
				return false

			# TODO: Update these once students decide final cost.
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
