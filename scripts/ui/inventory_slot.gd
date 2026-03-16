extends Panel

@onready var item_icon: TextureRect = $ItemIcon
@onready var count_label: Label = $CountLabel

func _ready() -> void:
	custom_minimum_size = Vector2(96, 96)

	item_icon.position = Vector2(16, 16)
	item_icon.size = Vector2(64, 64)
	item_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	item_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	item_icon.visible = false

	count_label.position = Vector2(58, 68)
	count_label.size = Vector2(30, 20)
	count_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	count_label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	count_label.add_theme_font_size_override("font_size", 18)
	count_label.text = ""

func set_empty() -> void:
	item_icon.texture = null
	item_icon.visible = false
	count_label.text = ""

func set_item(icon: Texture2D, count: int) -> void:
	item_icon.texture = icon
	item_icon.visible = true
	count_label.text = str(count)
