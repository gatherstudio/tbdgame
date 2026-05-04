extends Panel

@onready var item_icon: TextureRect = $ItemIcon
@onready var count_label: Label = $CountLabel

var item_id: String = ""

signal slot_clicked(item_id: String)

func _ready() -> void:
	# Make the whole slot small
	custom_minimum_size = Vector2(50, 50)

	# Important: make sure the slot receives mouse clicks
	mouse_filter = Control.MOUSE_FILTER_STOP

	# Icon stays INSIDE the slot
	item_icon.position = Vector2(6, 6)
	item_icon.size = Vector2(38, 38)
	item_icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	item_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	item_icon.visible = false

	# Let the click pass through to the slot panel
	item_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE

	# Count label stays INSIDE bottom-right corner
	count_label.position = Vector2(26, 30)
	count_label.size = Vector2(20, 16)
	count_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	count_label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	count_label.add_theme_font_size_override("font_size", 12)
	count_label.text = ""

	# Let the click pass through to the slot panel
	count_label.mouse_filter = Control.MOUSE_FILTER_IGNORE


func set_empty() -> void:
	item_id = ""
	item_icon.texture = null
	item_icon.visible = false
	count_label.text = ""


func set_item(icon: Texture2D, count: int, new_item_id: String) -> void:
	item_id = new_item_id
	item_icon.texture = icon
	item_icon.visible = true

	if count > 1:
		count_label.text = str(count)
	else:
		count_label.text = ""


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			if item_id != "":
				slot_clicked.emit(item_id)
