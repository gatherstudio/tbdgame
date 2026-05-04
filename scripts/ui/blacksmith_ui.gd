extends Control

@onready var background: ColorRect = $Background
@onready var blacksmith_panel: ColorRect = $BlacksmithPanel
@onready var blacksmith_portrait: TextureRect = $BlacksmithPortrait
@onready var title_label: Label = $TitleLabel
@onready var dialogue_label: Label = $DialogueLabel
@onready var materials_label: Label = $MaterialsLabel
@onready var upgrade_button: Button = $UpgradeButton
@onready var leave_button: Button = $LeaveButton

func _ready() -> void:
	_setup_layout()
	_connect_buttons()
	_update_blacksmith_ui()

func _setup_layout() -> void:
	# Root
	set_anchors_preset(Control.PRESET_FULL_RECT)
	position = Vector2.ZERO
	size = Vector2(1280, 720)

	# Background
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	background.offset_left = 0
	background.offset_top = 0
	background.offset_right = 0
	background.offset_bottom = 0
	background.color = Color.BLACK

	# Main panel, same style as battle scene
	blacksmith_panel.position = Vector2(110, 90)
	blacksmith_panel.size = Vector2(1060, 540)
	blacksmith_panel.color = Color(0.10, 0.10, 0.10, 1)

	# Title
	title_label.position = Vector2(145, 130)
	title_label.size = Vector2(600, 45)
	title_label.text = "Blacksmith Workshop"
	title_label.add_theme_font_size_override("font_size", 30)
	title_label.modulate = Color.WHITE

	# Dialogue
	dialogue_label.position = Vector2(145, 205)
	dialogue_label.size = Vector2(600, 155)
	dialogue_label.add_theme_font_size_override("font_size", 24)
	dialogue_label.modulate = Color.WHITE
	dialogue_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

	# Materials
	materials_label.position = Vector2(145, 375)
	materials_label.size = Vector2(600, 95)
	materials_label.add_theme_font_size_override("font_size", 22)
	materials_label.modulate = Color(0.9, 0.9, 0.9, 1)
	materials_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

	# Blacksmith portrait
	blacksmith_portrait.position = Vector2(820, 210)
	blacksmith_portrait.size = Vector2(220, 220)
	blacksmith_portrait.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	blacksmith_portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED

	# Buttons
	upgrade_button.position = Vector2(145, 505)
	upgrade_button.size = Vector2(300, 62)

	leave_button.position = Vector2(470, 505)
	leave_button.size = Vector2(220, 62)
	leave_button.text = "Leave"

func _connect_buttons() -> void:
	if not upgrade_button.pressed.is_connected(_on_upgrade_pressed):
		upgrade_button.pressed.connect(_on_upgrade_pressed)

	if not leave_button.pressed.is_connected(_on_leave_pressed):
		leave_button.pressed.connect(_on_leave_pressed)

func _update_blacksmith_ui() -> void:
	match GameState.weapon_level:
		1:
			dialogue_label.text = "Blacksmith:\nSo, I see you're still alive. Did you bring materials?\n\nI can turn that rusty spatula into something better."
			materials_label.text = "Need: 10 Screws + 3 Cans\nYou have: %d Screws + %d Cans" % [
				GameState.get_item_count("screws"),
				GameState.get_item_count("cans")
			]
			upgrade_button.text = "Make Frying Pan"
			upgrade_button.disabled = false

		2:
			dialogue_label.text = "Blacksmith:\nNot bad, not bad. But I can make it even stronger."
			materials_label.text = "Need: 15 Screws + 3 Cans\nYou have: %d Screws + %d Cans" % [
				GameState.get_item_count("screws"),
				GameState.get_item_count("cans")
			]
			upgrade_button.text = "Make Spiky Pan"
			upgrade_button.disabled = false

		3:
			dialogue_label.text = "Blacksmith:\nThis next one could be some of my best work."
			materials_label.text = "Final weapon cost is still being decided.\nCurrent idea: 20 Screws + 5 Cans + 3 Sea Glass"
			upgrade_button.text = "Final Upgrade"
			upgrade_button.disabled = false

		_:
			dialogue_label.text = "Blacksmith:\nYou're fully upgraded. Try not to die out there."
			materials_label.text = ""
			upgrade_button.text = "Fully Upgraded"
			upgrade_button.disabled = true

func _on_upgrade_pressed() -> void:
	var success := GameState.upgrade_weapon()

	if success:
		dialogue_label.text = "Blacksmith:\nI'll take those.\n\nCLANG CLANG CLANG!\n\nNow THAT'S a weapon."
	else:
		dialogue_label.text = "Blacksmith:\nYou seriously think that's enough for me to work with?\nCome back when you actually have the materials."

	await get_tree().create_timer(1.0).timeout
	_update_blacksmith_ui()

func _on_leave_pressed() -> void:
	get_tree().change_scene_to_file(GameState.return_scene_path)
