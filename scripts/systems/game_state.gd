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

# ==================================================
# CORE INVENTORY
# ==================================================

var inventory: Dictionary = {
	"banana": 0,
	"mushroom": 0,
	"screws": 0,
	"sea_glass": 0,
	"portal_shard": 0,
	"brains": 0
}

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


func reset_all() -> void:
	player_name = "Player"

	max_health = 15
	current_health = 15

	weapon_level = 1
	weapon_name = "Spatula"
	attack_power = 1
	armor_level = 0

	inventory = {
		"banana": 0,
		"mushroom": 0,
		"screws": 0,
		"sea_glass": 0,
		"portal_shard": 0,
		"brains": 0
	}

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


func get_brains() -> int:
	return get_item_count("brains")


func get_sea_glass() -> int:
	return get_item_count("sea_glass")

# ==================================================
# WEAPON UPGRADES
# Based on storyteller/dev notes
# ==================================================

func can_upgrade_to_frying_pan() -> bool:
	return has_item("screws", 10)


func can_upgrade_to_spiky_pan() -> bool:
	return has_item("screws", 15)


func upgrade_weapon() -> bool:
	match weapon_level:
		1:
			if not can_upgrade_to_frying_pan():
				return false

			remove_item("screws", 10)
			weapon_level = 2
			weapon_name = "Frying Pan"
			attack_power = 3
			armor_level = 1
			set_max_health(20)
			return true

		2:
			if not can_upgrade_to_spiky_pan():
				return false

			remove_item("screws", 15)
			weapon_level = 3
			weapon_name = "Spiky Frying Pan"
			attack_power = 5
			armor_level = 2
			set_max_health(25)
			return true

		_:
			return false
