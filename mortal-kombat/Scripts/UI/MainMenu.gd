extends Control

# Ruta de tu escena de pelea (la que abres al pulsar "Jugar").
# Cámbiala por la ruta real de tu escena principal del juego.
const GAME_SCENE_PATH := "res://main/main.tscn"
const SETTINGS_SCENE_PATH := "res://Scenes/UI/SettingsMenu.tscn"

@onready var play_button: Button = $CenterContainer/VBoxContainer/PlayButton
@onready var settings_button: Button = $CenterContainer/VBoxContainer/SettingsButton
@onready var quit_button: Button = $CenterContainer/VBoxContainer/QuitButton

func _ready() -> void:
	play_button.pressed.connect(_on_play_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	play_button.grab_focus()

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file(GAME_SCENE_PATH)

func _on_settings_pressed() -> void:
	get_tree().change_scene_to_file(SETTINGS_SCENE_PATH)

func _on_quit_pressed() -> void:
	get_tree().quit()
