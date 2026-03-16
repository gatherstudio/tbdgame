extends CanvasLayer

@onready var backpack_button: Button = $BackpackButton
@onready var inventory_panel: Panel = $InventoryPanel
@onready var title_label: Label = $InventoryPanel/TitleLabel
@onready var grid_container: GridContainer = $InventoryPanel/GridContainer

const SLOT_SCENE = preload("res://scenes/ui/InventorySlot.tscn")

var slots: Array = []

var item_icons := {
	#"banana": preload("res://assets/art/items/banana.png"),
	"mushroom": preload("res://assets/art/items/mushroom.png"),
	#"screws": preload("res://assets/art/items/screws.png"),
	#"sea_glass": preload("res://assets/art/items/sea_glass.png"),
	"portal_shard": preload("res://assets/art/items/shards.png"),
	"brains": preload("res://assets/art/items/brains.png"),
	"cans": preload("res://assets/art/items/can.png")
}

func _ready() -> void:
	setup_layout()
	create_slots()
	inventory_panel.visible = false
	refresh_inventory()

func setup_layout() -> void:
	backpack_button.position = Vector2(2400, 20)
	backpack_button.size = Vector2(300, 100)
	backpack_button.text = " Inventory "
	backpack_button.add_theme_font_size_override("font_size", 50)

	inventory_panel.position = Vector2(2400, 122)
	inventory_panel.size = Vector2(600, 600)

	title_label.position = Vector2(24, 16)
	title_label.size = Vector2(260, 40)
	title_label.text = ""
	title_label.add_theme_font_size_override("font_size", 40)

	grid_container.position = Vector2(40, 70)
	grid_container.size = Vector2(760, 430)
	grid_container.columns = 5
	grid_container.add_theme_constant_override("h_separation", 12)
	grid_container.add_theme_constant_override("v_separation", 12)

func create_slots() -> void:
	for i in range(20):
		var slot = SLOT_SCENE.instantiate()
		grid_container.add_child(slot)
		slots.append(slot)

func toggle_inventory() -> void:
	inventory_panel.visible = not inventory_panel.visible
	if inventory_panel.visible:
		refresh_inventory()

func refresh_inventory() -> void:
	for slot in slots:
		slot.set_empty()

	var item_list: Array = []

	for item_id in GameState.inventory.keys():
		if GameState.inventory[item_id] > 0:
			item_list.append(item_id)

	for i in range(min(item_list.size(), slots.size())):
		var item_id = item_list[i]
		var amount = GameState.inventory[item_id]
		var icon = item_icons.get(item_id, null)

		if icon != null:
			slots[i].set_item(icon, amount)


func _on_backpack_button_pressed() -> void:
	toggle_inventory()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("inventory"):
		toggle_inventory()
