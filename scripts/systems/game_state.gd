extends Node
"""
Stores simple global data that persists across scene changes.
"""

# ============================================================
# STUDENT DEVELOPER ZONE
# ============================================================

var scrap_count: int = 0
var water_count: int = 0
var mushroom_count: int = 0

# ============================================================
# CORE LOGIC
# ============================================================

func add_item(item_id: StringName, amount: int = 1) -> void:
	if amount <= 0:
		return

	match item_id:
		&"scrap":
			scrap_count += amount
		&"water":
			water_count += amount
		&"mushroom":
			mushroom_count += amount
		_:
			push_warning("Unknown item_id: %s" % item_id)

func reset_all() -> void:
	scrap_count = 0
	water_count = 0
	mushroom_count = 0
