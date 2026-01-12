extends Control
"""
INTRO STORY SCENE

Loads intro text from a .txt file and displays it one line at a time.
Each line appears centered, fades in, holds briefly, then fades out.
"""

# ============================================================
# STUDENT DEVELOPER ZONE
# Safe to edit values in this section.
# ============================================================

@export var story_text_path: String = "res://data/story/intro_story.txt"

@export_multiline var fallback_story_text: String = """Welcome to our game.

This is the beginning of our story.
Press Continue to enter the world."""

@export var world_scene_path: String = "res://scenes/world/WorldSurface.tscn"

# Timing controls (seconds)
@export var fade_in_time: float = 0.6
@export var hold_time: float = 1.2
@export var fade_out_time: float = 0.6

# Extra pause for blank lines in the text file
@export var blank_line_pause: float = 0.8

# Allow skipping the intro with any key or mouse click
@export var allow_skip_with_any_input: bool = true

# ============================================================
# CORE LOGIC
# ============================================================

@onready var story_label: Label = $CanvasLayer/CenterContainer/VBoxContainer/StoryLabel
@onready var continue_button: Button = $CanvasLayer/CenterContainer/VBoxContainer/ContinueButton

var _lines: PackedStringArray
var _current_line_index: int = 0
var _skipping: bool = false

func _ready() -> void:
	# Load story text and split into lines
	var full_text := _load_story_text(story_text_path)
	_lines = full_text.split("\n")

	# Start with no text visible
	story_label.text = ""
	story_label.modulate.a = 0.0

	# Hide Continue until the intro finishes (or is skipped)
	continue_button.visible = false
	continue_button.pressed.connect(_on_continue_pressed)

	# Run the reveal sequence
	_run_intro()


func _unhandled_input(event: InputEvent) -> void:
	if not allow_skip_with_any_input:
		return

	if event.is_pressed():
		_skip_intro()


func _skip_intro() -> void:
	# Stop the sequence and reveal the Continue button
	_skipping = true
	story_label.modulate.a = 0.0
	continue_button.visible = true


func _run_intro() -> void:
	# Start an async sequence without blocking the game
	_show_next_line_async()


func _show_next_line_async() -> void:
	# If skipped or finished, show Continue and stop
	if _skipping:
		return

	if _current_line_index >= _lines.size():
		story_label.text = ""
		story_label.modulate.a = 0.0
		continue_button.visible = true
		return

	var line := _lines[_current_line_index]
	_current_line_index += 1

	# Blank lines become a dramatic pause (no text shown)
	if line.strip_edges() == "":
		story_label.text = ""
		story_label.modulate.a = 0.0
		await get_tree().create_timer(blank_line_pause).timeout
		_show_next_line_async()
		return

	# Show the line centered (Label placement handles centering)
	story_label.text = line

	# Fade in -> hold -> fade out
	await _fade_label_to(1.0, fade_in_time)
	if _skipping: return

	await get_tree().create_timer(hold_time).timeout
	if _skipping: return

	await _fade_label_to(0.0, fade_out_time)
	if _skipping: return

	# Next line
	_show_next_line_async()


func _fade_label_to(target_alpha: float, duration: float) -> void:
	# Safety: instant change if duration is 0
	if duration <= 0.0:
		story_label.modulate.a = target_alpha
		return

	var tween := create_tween()
	tween.tween_property(story_label, "modulate:a", target_alpha, duration)
	await tween.finished


func _on_continue_pressed() -> void:
	get_tree().change_scene_to_file(world_scene_path)


func _load_story_text(path: String) -> String:
	if not FileAccess.file_exists(path):
		push_warning("Story file not found: " + path)
		return fallback_story_text

	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_warning("Could not open story file: " + path)
		return fallback_story_text

	return file.get_as_text()
