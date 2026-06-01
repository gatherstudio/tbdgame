extends CanvasLayer

@onready var backpack_button: Button = $BackpackButton
@onready var inventory_panel: Panel = $InventoryPanel
@onready var title_label: Label = $InventoryPanel/TitleLabel
@onready var grid_container: GridContainer = $InventoryPanel/GridContainer

const SLOT_SCENE = preload("res://scenes/ui/InventorySlot.tscn")
const BAG_ICON = preload("res://assets/art/items/bag.png")

var slots: Array = []

const MAX_SLOTS := 12

var item_icons := {
	"banana": preload("res://assets/art/items/bananas.png"),
	"mushroom": preload("res://assets/art/items/mushroom.png"),
	"portal_shard": preload("res://assets/art/items/shards.png"),
	"brains": preload("res://assets/art/items/brains.png"),
	"cans": preload("res://assets/art/items/can.png"),
	"screws": preload("res://assets/art/items/screw.png"),
	"sea_glass": preload("res://assets/art/items/seaglass.png")
}

func _ready() -> void:
	setup_layout()
	create_slots()
	inventory_panel.visible = false
	refresh_inventory()


func setup_layout() -> void:
	layer = 10

	# -------------------------------------------------
	# BAG ICON BUTTON
	# -------------------------------------------------
	backpack_button.position = Vector2(1198, 12)
	backpack_button.size = Vector2(64, 64)
	backpack_button.custom_minimum_size = Vector2(64, 64)

	backpack_button.text = ""
	backpack_button.icon = BAG_ICON
	backpack_button.expand_icon = true
	backpack_button.flat = true
	backpack_button.clip_text = false
	backpack_button.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER

	# -------------------------------------------------
	# PANEL
	# -------------------------------------------------
	inventory_panel.position = Vector2(430, 180)
	inventory_panel.size = Vector2(420, 190)

	# -------------------------------------------------
	# TITLE
	# -------------------------------------------------
	title_label.position = Vector2(16, 10)
	title_label.size = Vector2(300, 24)
	title_label.text = "Inventory"
	title_label.add_theme_font_size_override("font_size", 18)

	# -------------------------------------------------
	# GRID
	# -------------------------------------------------
	grid_container.position = Vector2(18, 42)
	grid_container.size = Vector2(385, 118)
	grid_container.columns = 6
	grid_container.add_theme_constant_override("h_separation", 8)
	grid_container.add_theme_constant_override("v_separation", 8)


func create_slots() -> void:
	for child in grid_container.get_children():
		child.queue_free()

	slots.clear()

	for i in range(MAX_SLOTS):
		var slot = SLOT_SCENE.instantiate()
		grid_container.add_child(slot)
		slots.append(slot)

		# Listen for clicks from each slot
		slot.slot_clicked.connect(_on_inventory_slot_clicked)


func toggle_inventory() -> void:
	inventory_panel.visible = not inventory_panel.visible

	if inventory_panel.visible:
		title_label.text = "Inventory"
		refresh_inventory()


func refresh_inventory() -> void:
	for slot in slots:
		slot.set_empty()

	var item_list: Array = []

	for item_id in GameState.inventory.keys():
		if GameState.inventory[item_id] > 0:
			item_list.append(item_id)

	item_list.sort()

	for i in range(min(item_list.size(), slots.size())):
		var item_id = item_list[i]
		var amount = GameState.inventory[item_id]
		var icon = item_icons.get(item_id, null)

		if icon != null:
			# Important: pass item_id into the slot
			slots[i].set_item(icon, amount, item_id)
		else:
			slots[i].set_empty()


func _on_inventory_slot_clicked(item_id: String) -> void:
	match item_id:
		"mushroom":
			var used := GameState.use_item("mushroom")

			if used:
				title_label.text = "Ate mushroom (+2 HP)"
				_play_eat_sound()
				refresh_inventory()

		"banana":
			var used := GameState.use_item("banana")

			if used:
				title_label.text = "Ate banana (full heal)"
				_play_eat_sound()
				refresh_inventory()

		_:
			title_label.text = "Can't eat that"


func _play_eat_sound() -> void:
	if has_node("EatSound"):
		$EatSound.stop()
		$EatSound.play()


func _on_backpack_button_pressed() -> void:
	toggle_inventory()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("inventory"):
		toggle_inventory()
