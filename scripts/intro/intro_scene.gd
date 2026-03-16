extends Node2D

@onready var camera: Camera2D = $Camera2D
@onready var intro_music = $IntroMusic
@onready var player_ghost = $PlayerGhost
@onready var npc_ghost = $NPCGhost

@onready var dialogue_box = $DialogueLayer/DialogueBox
@onready var speaker_label = $DialogueLayer/DialogueBox/SpeakerLabel
@onready var dialogue_label = $DialogueLayer/DialogueBox/DialogueLabel
@onready var continue_label = $DialogueLayer/DialogueBox/ContinueLabel

@onready var name_input = $DialogueLayer/DialogueBox/NameInput
@onready var confirm_button = $DialogueLayer/DialogueBox/ConfirmNameButton
@onready var advance_button = $DialogueLayer/DialogueBox/AdvanceButton

var intro_steps = [
	{"action":"set_player_down"},
	{"action":"say","speaker":"thought","text":"Where am I?"},
	{"action":"say","speaker":"thought","text":"How do I get home?"},
	{"action":"stand_player_up"},
	{"action":"move_npc_in"},
	{"action":"say","speaker":"npc","text":"What are you doing down here?"},
	{"action":"say","speaker":"npc","text":"It isn't safe."},
	{"action":"say","speaker":"npc","text":"The portal exploded not long ago."},
	{"action":"say","speaker":"npc","text":"Its shards were scattered across the land."},
	{"action":"ask_name"},
	{"action":"say","speaker":"npc","text":"Come with me, {player_name}."},
	{"action":"walk_offscreen"},
	{"action":"change_scene","path":"res://scenes/world/WorldSurface.tscn"}
]

var step_index := 0
var can_advance := false
var waiting_for_name := false
var busy := false

var full_line_text := ""
var is_typing := false
var typing_speed := 0.025


func _ready() -> void:
	setup_layout()
	intro_music.play()
	npc_ghost.play()
	run_step()


func setup_layout() -> void:
	# ------------------------------------------------------------
	# CAMERA / VIEW CENTERING
	# ------------------------------------------------------------
	# This is the center point of the intro scene.
	var scene_center := Vector2(640, 360)
	camera.position = scene_center

	# ------------------------------------------------------------
	# GHOST PLACEMENT
	# ------------------------------------------------------------
	# Keep both characters around the center of the screen instead of top-left.
	player_ghost.position = Vector2(500, 330)
	npc_ghost.position = Vector2(900, 200)

	# Start player sideways / unconscious.
	player_ghost.rotation_degrees = 90

	# ------------------------------------------------------------
	# DIALOGUE BOX PLACEMENT
	# ------------------------------------------------------------
	dialogue_box.position = Vector2(1300, 1600)
	dialogue_box.size = Vector2(1000, 200)

	speaker_label.position = Vector2(24, 14)
	dialogue_label.position = Vector2(24, 60)
	dialogue_label.size = Vector2(780, 60)

	continue_label.position = Vector2(780, 110)
	continue_label.size = Vector2(190, 20)

	name_input.position = Vector2(24, 130)
	name_input.size = Vector2(300, 34)

	confirm_button.position = Vector2(340, 130)
	confirm_button.size = Vector2(150, 34)
	confirm_button.text = "Confirm"

	advance_button.position = Vector2(0, 0)
	advance_button.size = dialogue_box.size
	advance_button.text = ""

	# ------------------------------------------------------------
	# UI START STATE
	# ------------------------------------------------------------
	name_input.visible = false
	confirm_button.visible = false
	continue_label.text = ""

	# Make sure the large tap button does not block name entry later.
	advance_button.mouse_filter = Control.MOUSE_FILTER_STOP

	# ------------------------------------------------------------
	# FONT SIZES
	# ------------------------------------------------------------
	speaker_label.add_theme_font_size_override("font_size", 40)
	dialogue_label.add_theme_font_size_override("font_size", 40)
	continue_label.add_theme_font_size_override("font_size", 20)
	name_input.add_theme_font_size_override("font_size", 20)
	confirm_button.add_theme_font_size_override("font_size", 20)


func run_step() -> void:
	if step_index >= intro_steps.size():
		return

	if busy:
		return

	var step = intro_steps[step_index]
	var action = step["action"]

	match action:
		"set_player_down":
			player_ghost.rotation_degrees = 90
			step_index += 1
			run_step()

		"say":
			show_dialogue(step["speaker"], step["text"])
			can_advance = true

		"stand_player_up":
			busy = true
			await stand_player()
			busy = false
			step_index += 1
			run_step()

		"move_npc_in":
			busy = true
			await move_npc()
			busy = false
			step_index += 1
			run_step()

		"ask_name":
			show_name_prompt()

		"walk_offscreen":
			busy = true
			clear_dialogue()
			await walk_off()
			busy = false
			step_index += 1
			run_step()

		"change_scene":
			intro_music.stop()
			get_tree().change_scene_to_file(step["path"])


func show_dialogue(speaker, text) -> void:
	var final_text = text.replace("{player_name}", GameState.player_name)

	match speaker:
		"thought":
			speaker_label.text = "Thought"
			speaker_label.modulate = Color(0.8, 0.95, 1.0)
			dialogue_label.modulate = Color(0.8, 0.95, 1.0)
		"npc":
			speaker_label.text = "Scavenger"
			speaker_label.modulate = Color(1, 1, 1)
			dialogue_label.modulate = Color(1, 1, 1)
		_:
			speaker_label.text = ""
			speaker_label.modulate = Color(1, 1, 1)
			dialogue_label.modulate = Color(1, 1, 1)

	full_line_text = final_text
	dialogue_label.text = ""
	continue_label.text = ""
	start_typewriter(final_text)


func start_typewriter(text: String) -> void:
	is_typing = true
	dialogue_label.text = ""

	for i in range(text.length()):
		# If player clicked while typing, reveal all immediately.
		if not is_typing:
			dialogue_label.text = text
			continue_label.text = "Tap / click / press Enter"
			return

		dialogue_label.text += text[i]
		await get_tree().create_timer(typing_speed).timeout

	is_typing = false
	continue_label.text = "Tap / click / press Enter"


func finish_typing() -> void:
	if is_typing:
		is_typing = false
		dialogue_label.text = full_line_text
		continue_label.text = "Tap / click / press Enter"


func clear_dialogue() -> void:
	speaker_label.text = ""
	dialogue_label.text = ""
	continue_label.text = ""


func advance() -> void:
	if busy:
		return

	if waiting_for_name:
		return

	if not can_advance:
		return

	# First tap finishes the typewriter.
	if is_typing:
		finish_typing()
		return

	# Second tap advances to the next step.
	can_advance = false
	step_index += 1
	run_step()


func _unhandled_input(event) -> void:
	if event.is_action_pressed("ui_accept"):
		advance()
		return

	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		advance()
		return

	if event is InputEventScreenTouch and event.pressed:
		advance()
		return


func _on_AdvanceButton_pressed() -> void:
	advance()


func stand_player() -> void:
	var tween = create_tween()
	tween.tween_property(player_ghost, "rotation_degrees", 0, 0.45)
	await tween.finished


func move_npc() -> void:
	var tween = create_tween()
	tween.tween_property(npc_ghost, "position:x", 720, 1.2)
	await tween.finished


func walk_off() -> void:
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(player_ghost, "position:x", 2000, 2.0)
	tween.tween_property(npc_ghost, "position:x", 1740, 2.0)
	await tween.finished


func show_name_prompt() -> void:
	speaker_label.text = "Scavenger"
	speaker_label.modulate = Color(1, 1, 1)
	dialogue_label.modulate = Color(1, 1, 1)
	dialogue_label.text = "Wait... what is your name?"
	continue_label.text = ""

	name_input.visible = true
	confirm_button.visible = true
	name_input.text = ""
	name_input.placeholder_text = "Type your name here"

	# IMPORTANT: disable the big advance button so it doesn't steal clicks.
	advance_button.visible = false
	advance_button.mouse_filter = Control.MOUSE_FILTER_IGNORE

	name_input.grab_focus()
	waiting_for_name = true
	is_typing = false


# ============================================================
# STUDENT DEVELOPER ZONE
# ============================================================
# Students:
# 1. Read the typed name from the input box
# 2. If blank, use "Traveler"
# 3. Save it to GameState.player_name
# 4. Hide the input UI
# 5. Turn the advance button back on
# 6. Continue the cutscene


func _on_NameInput_text_submitted(_new_text: String) -> void:
	_on_confirm_name_button_pressed()

func _on_confirm_name_button_pressed() -> void:

	# Get the name the player typed
	var typed_name = name_input.text.strip_edges()

	# If the player left it blank, use a default name
	if typed_name == "":
		typed_name = "Traveler"

	# Save the name globally so other scenes can use it
	GameState.player_name = typed_name

	# Hide the name input UI
	name_input.visible = false
	confirm_button.visible = false

	# Turn the advance button back on so dialogue can continue
	advance_button.visible = true
	advance_button.mouse_filter = Control.MOUSE_FILTER_STOP

	waiting_for_name = false

	# Continue the intro cutscene
	step_index += 1
	run_step()
