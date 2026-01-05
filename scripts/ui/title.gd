extends Control
"""
TITLE SCENE

This is the first screen players see when the game starts.
It shows the game title and allows the player to start or quit.

Technical notes:
- Buttons emit a signal when pressed.
- Signals are connected in _ready() so they respond to clicks.
"""

# ============================================================
# STUDENT DEVELOPER ZONE
# Safe to edit values in this section.
# ============================================================

# Path to the scene that plays after pressing Start
@export var intro_story_scene_path: String = "res://scenes/ui/IntroStory.tscn"

# Text displayed as the game title
@export var game_title_text: String = "To Be Decided Game"

# ============================================================
# CORE LOGIC
# Edit only if you understand the full flow.
# ============================================================

func _ready() -> void:
	# Set the title text when the scene loads
	$CanvasLayer/CenterContainer/VBoxContainer/GameTitleLabel.text = game_title_text

	# Connect button signals so they trigger code when pressed
	$CanvasLayer/CenterContainer/VBoxContainer/StartButton.pressed.connect(_on_start_pressed)
	$CanvasLayer/CenterContainer/VBoxContainer/QuitButton.pressed.connect(_on_quit_pressed)


func _on_start_pressed() -> void:
	# Move from the title screen to the intro story scene
	get_tree().change_scene_to_file(intro_story_scene_path)


func _on_quit_pressed() -> void:
	# Close the game application
	get_tree().quit()
