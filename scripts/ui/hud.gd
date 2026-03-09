extends CanvasLayer
"""
Displays simple counters from GameState.
"""

# ============================================================
# STUDENT DEVELOPER ZONE
# ============================================================

@export var show_scrap: bool = true
@export var show_mushrooms: bool = true
@export var show_water: bool = true

@export var label_prefix: String = ""

# ============================================================
# CORE LOGIC
# ============================================================

@onready var counter_label: Label = $Root/CounterLabel

func _process(_delta: float) -> void:
	if counter_label == null:
		return

	counter_label.text = _build_text()

func _build_text() -> String:
	var parts: Array[String] = []
	parts.append("Traveler %s" % GameState.player_name)
	if show_scrap:
		parts.append("Scrap: %d" % GameState.scrap_count)
	if show_mushrooms:
		parts.append("Mushrooms: %d" % GameState.mushroom_count)
	if show_water:
		parts.append("Water: %d" % GameState.water_count)

	var joined := " | ".join(parts)

	if label_prefix.strip_edges() != "":
		return "%s%s" % [label_prefix, joined]

	return joined
