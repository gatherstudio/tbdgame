extends Node2D

@onready var camera: Camera2D = $Camera2D
@onready var intro_music = $IntroMusic
@onready var color_rect: ColorRect = $ColorRect
@onready var hut = $Hut

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
	{"action":"say","speaker":"npc","text":"The portal has been dormant for ages, but it exploded not long ago."},
	{"action":"say","speaker":"npc","text":"It's shards were scattered all across the land."},
	{"action":"say","speaker":"npc","text":"I came to see what happened."},
	{"action":"ask_name"},
	{"action":"say","speaker":"npc","text":"Come with me, {player_name}."},

	{"action":"move_to_walk_scene"},

	{"action":"say","speaker":"npc","text":"Long, long ago, your people discovered a mysterious portal in the depths of the earth."},
	{"action":"say","speaker":"npc","text":"They found out they could send their trash through the portal."},
	{"action":"say","speaker":"npc","text":"Over hundreds of years, that trash built up."},
	{"action":"say","speaker":"npc","text":"Trash monsters are now living below ground."},
	{"action":"say","speaker":"npc","text":"I hide above ground in my hut."},
	{"action":"say","speaker":"npc","text":"Come on. I'll show you."},

	{"action":"walk_together"},
	{"action":"say","speaker":"npc","text":"Oh, you want to see for yourself? Here's something to protect yourself... *receives spatula*"},
	{"action":"change_scene","path":"res://scenes/ui/TitleReveal.tscn"}
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
	
	color_rect.visible = true
	color_rect.color = Color(0, 0, 0, 1)

	if intro_music:
		intro_music.play()

	if player_ghost.has_method("play"):
		player_ghost.play()
	if npc_ghost.has_method("play"):
		npc_ghost.play()

	await fade_from_black()
	run_step()


func setup_layout() -> void:
	# CAMERA
	camera.enabled = true
	camera.position = Vector2(640, 360)
	camera.zoom = Vector2(1, 1)

	# CHARACTERS
	player_ghost.position = Vector2(380, 340)
	npc_ghost.position = Vector2(560, 335)
	player_ghost.rotation_degrees = 90

	# HUT
	hut.visible = false
	hut.position = Vector2(1500, 250)

	# DIALOGUE UI
	$DialogueLayer.layer = 10
	$DialogueLayer.visible = true

	dialogue_box.visible = true
	dialogue_box.position = Vector2(110, 500)
	dialogue_box.size = Vector2(1060, 170)

	speaker_label.position = Vector2(20, 10)
	speaker_label.size = Vector2(260, 24)

	dialogue_label.position = Vector2(20, 42)
	dialogue_label.size = Vector2(920, 65)

	continue_label.position = Vector2(790, 135)
	continue_label.size = Vector2(240, 20)

	name_input.position = Vector2(20, 105)
	name_input.size = Vector2(300, 32)

	confirm_button.position = Vector2(340, 105)
	confirm_button.size = Vector2(150, 32)
	confirm_button.text = "Confirm"

	advance_button.position = Vector2(0, 0)
	advance_button.size = dialogue_box.size
	advance_button.text = ""

	speaker_label.add_theme_font_size_override("font_size", 20)
	dialogue_label.add_theme_font_size_override("font_size", 28)
	continue_label.add_theme_font_size_override("font_size", 14)
	name_input.add_theme_font_size_override("font_size", 18)
	confirm_button.add_theme_font_size_override("font_size", 18)

	speaker_label.modulate = Color(1, 1, 1)
	dialogue_label.modulate = Color(1, 1, 1)
	continue_label.modulate = Color(1, 1, 1)

	name_input.visible = false
	confirm_button.visible = false
	continue_label.text = ""

	advance_button.mouse_filter = Control.MOUSE_FILTER_STOP


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

			# Once the hut scene begins, slowly slide the hut closer on each dialogue line
			if hut.visible and step_index >= 13:
				nudge_hut_closer(60.0)

			can_advance = true

		"stand_player_up":
			busy = true
			await stand_player()
			busy = false
			step_index += 1
			run_step()

		"move_npc_in":
			busy = true
			await move_npc_in()
			busy = false
			step_index += 1
			run_step()

		"ask_name":
			show_name_prompt()

		"move_to_walk_scene":
			busy = true
			clear_dialogue()
			await fade_to_black()
			await get_tree().create_timer(0.2).timeout
			await reposition_for_walk_scene()
			await fade_to_tan()
			busy = false
			step_index += 1
			run_step()

		"walk_together":
			busy = true
			await walk_together()
			busy = false
			step_index += 1
			run_step()

		"change_scene":
			if intro_music:
				intro_music.stop()
			get_tree().change_scene_to_file(step["path"])


func show_dialogue(speaker: String, text: String) -> void:
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

	if is_typing:
		finish_typing()
		return

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


func _on_advance_button_pressed() -> void:
	advance()


func stand_player() -> void:
	var tween = create_tween()
	tween.tween_property(player_ghost, "rotation_degrees", 0, 0.45)
	await tween.finished


func move_npc_in() -> void:
	var tween = create_tween()
	tween.tween_property(npc_ghost, "position:x", 760, 1.2)
	await tween.finished


func reposition_for_walk_scene() -> void:
	player_ghost.rotation_degrees = 0
	hut.visible = true
	hut.position = Vector2(1500, 320)

	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(player_ghost, "position", Vector2(380, 420), 0.8)
	tween.tween_property(npc_ghost, "position", Vector2(560, 420), 0.8)
	await tween.finished


func walk_together() -> void:
	var tween = create_tween()
	tween.set_parallel(true)

	# characters move a little
	tween.tween_property(player_ghost, "position:x", 470, 2.5)
	tween.tween_property(npc_ghost, "position:x", 650, 2.5)

	# hut moves in much more to create the illusion
	tween.tween_property(hut, "position:x", 860, 2.5)

	await tween.finished


func nudge_hut_closer(amount: float = 60.0) -> void:
	if not hut.visible:
		return

	var tween = create_tween()
	tween.tween_property(hut, "position:x", hut.position.x - amount, 0.6)


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

	advance_button.visible = false
	advance_button.mouse_filter = Control.MOUSE_FILTER_IGNORE

	name_input.grab_focus()
	waiting_for_name = true
	is_typing = false


func _on_name_input_text_submitted(_new_text: String) -> void:
	_on_confirm_name_button_pressed()


func _on_confirm_name_button_pressed() -> void:
	var typed_name = name_input.text.strip_edges()

	if typed_name == "":
		typed_name = "Traveler"

	GameState.player_name = typed_name

	name_input.visible = false
	confirm_button.visible = false

	advance_button.visible = true
	advance_button.mouse_filter = Control.MOUSE_FILTER_STOP

	waiting_for_name = false
	step_index += 1
	run_step()


func fade_from_black() -> void:
	var tween = create_tween()
	tween.tween_property(color_rect, "color", Color(0, 0, 0, 0), 1.5)
	await tween.finished


func fade_to_black() -> void:
	var tween = create_tween()
	tween.tween_property(color_rect, "color", Color(0, 0, 0, 1), 0.6)
	await tween.finished


func fade_to_tan() -> void:
	var tan_color = Color(0.72, 0.69, 0.60, 1.0)
	var tween = create_tween()
	tween.tween_property(color_rect, "color", tan_color, 1.2)
	await tween.finished
