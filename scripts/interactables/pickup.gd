extends Area2D

# ============================================================
# STUDENT DEVELOPER ZONE
# ============================================================

@export_enum("scrap", "mushroom", "water") var item_id: String = "scrap"
@export_enum("scrap", "mushroom", "water") var icon_id: String = "scrap"

@export var amount: int = 1
@export var consume_on_collect: bool = true

# ============================================================
# CORE LOGIC
# ============================================================

@onready var icon: Sprite2D = $Icon

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	_update_icon()

func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("player"):
		return

	GameState.add_item(StringName(item_id), amount)

	if consume_on_collect:
		queue_free()

func _update_icon() -> void:
	var texture_path := ""

	match icon_id:
		"scrap":
			texture_path = "res://assets/art/items/scrap.png"
		"mushroom":
			texture_path = "res://assets/art/items/mushroom.png"
		"water":
			texture_path = "res://assets/art/items/water.png"

	if texture_path != "":
		icon.texture = load(texture_path)
