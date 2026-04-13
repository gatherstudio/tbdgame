extends CanvasLayer

@onready var stats_panel: Panel = $StatsPanel
@onready var stats_vbox: VBoxContainer = $StatsPanel/StatsVBox

@onready var player_name_label: Label = $StatsPanel/StatsVBox/PlayerNameLabel
@onready var health_label: Label = $StatsPanel/StatsVBox/HealthLabel
@onready var attack_label: Label = $StatsPanel/StatsVBox/AttackLabel
@onready var weapon_label: Label = $StatsPanel/StatsVBox/WeaponLabel
@onready var shards_label: Label = $StatsPanel/StatsVBox/ShardsLabel


func _ready() -> void:
	setup_layout()
	update_stats()


func _process(_delta: float) -> void:
	update_stats()


func setup_layout() -> void:
	layer = 10

	# Compact stat panel in upper-left
	stats_panel.position = Vector2(20, 20)
	stats_panel.size = Vector2(235, 112)

	stats_vbox.position = Vector2(10, 8)
	stats_vbox.size = Vector2(215, 96)
	stats_vbox.add_theme_constant_override("separation", 1)

	player_name_label.add_theme_font_size_override("font_size", 14)
	health_label.add_theme_font_size_override("font_size", 14)
	attack_label.add_theme_font_size_override("font_size", 14)
	weapon_label.add_theme_font_size_override("font_size", 14)
	shards_label.add_theme_font_size_override("font_size", 14)

	player_name_label.text = "PLAYER  Player"
	health_label.text = "HP      15 / 15"
	attack_label.text = "ATK     1"
	weapon_label.text = "WEAPON  Spatula"
	shards_label.text = "SHARDS  0 / 10"

func update_stats() -> void:
	player_name_label.text = "NAME   %s" % GameState.player_name
	health_label.text = "HP     %d / %d" % [GameState.current_health, GameState.max_health]
	attack_label.text = "ATK    %d" % GameState.attack_power
	weapon_label.text = "WEAPON   %s" % GameState.weapon_name
	shards_label.text = "SHARD   %d / 10" % GameState.get_portal_shards()
