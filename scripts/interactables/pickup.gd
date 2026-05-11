extends Area2D

# ============================================================
# STUDENT DEVELOPER ZONE
# ============================================================

@export_enum("scrap", "mushroom", "banana", "screws", "sea_glass", "portal_shard", "brains", "cans") var item_id: String = "scrap"

@export_enum("scrap", "mushroom", "banana", "screws", "sea_glass", "portal_shard", "brains", "cans") var icon_id: String = "scrap"

@export var amount: int = 1
@export var consume_on_collect: bool = true

# Used by WorldUnderground to remember which food spots were collected.
@export var spawn_id: String = ""

# ============================================================
# CORE LOGIC
# ============================================================

@onready var icon: Sprite2D = $Icon

var item_icons := {
	"scrap": preload("res://assets/art/items/scrap.png"),
	"mushroom": preload("res://assets/art/items/mushroom.png"),
	"banana": preload("res://assets/art/items/bananas.png"),
	"screws": preload("res://assets/art/items/screw.png"),
	# "sea_glass": preload("res://assets/art/items/sea_glass.png"),
	"portal_shard": preload("res://assets/art/items/shards.png"),
	"brains": preload("res://assets/art/items/brains.png"),
	"cans": preload("res://assets/art/items/can.png")
}


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	_update_icon()


func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("player"):
		return

	var sound_player = get_tree().get_first_node_in_group("collect_sound_player")
	if sound_player:
		sound_player.play()

	GameState.add_item(StringName(item_id), amount)

	if spawn_id != "":
		if not GameState.underground_collected_food_this_visit.has(spawn_id):
			GameState.underground_collected_food_this_visit.append(spawn_id)
			
	GameState.save_game()

	if consume_on_collect:
		queue_free()


func _update_icon() -> void:
	if item_icons.has(icon_id):
		icon.texture = item_icons[icon_id]
