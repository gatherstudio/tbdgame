extends Node
"""
Stores simple global data that persists across scene changes.
"""

# ============================================================
# STUDENT DEVELOPER ZONE
# ============================================================
var player_name: String = "Traveler"
var scrap_count: int = 0
var water_count: int = 0
var mushroom_count: int = 0

# ============================================================
# CORE LOGIC
# ============================================================
var inventory: Dictionary = {
	"banana": 0,
	"mushroom": 0,
	"screws": 0,
	"sea_glass": 0,
	"portal_shard": 0,
	"brains": 0
}

func add_item(item_id: String, amount: int = 1) -> void:
	if not inventory.has(item_id):
		inventory[item_id] = 0

	inventory[item_id] += amount


func reset_all() -> void:
	scrap_count = 0
	water_count = 0
	mushroom_count = 0
