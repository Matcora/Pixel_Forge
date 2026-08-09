extends CanvasLayer

const SETTINGS_SCENE_PATH := "res://Scenes/UI/SettingsMenu.tscn"
const MAIN_MENU_SCENE_PATH := "res://Scenes/UI/MainMenu.tscn"

@onready var panel: Control = $Control
@onready var resume_button: Button = $Control/CenterContainer/VBoxContainer/ResumeButton
@onready var settings_button: Button = $Control/CenterContainer/VBoxContainer/SettingsButton
@onready var main_menu_button: Button = $Control/CenterContainer/VBoxContainer/MainMenuButton
@onready var quit_button: Button = $Control/CenterContainer/VBoxContainer/QuitButton

func _ready() -> void:
	# Para que este menú siga funcionando aunque el juego esté en pausa.
	process_mode = Node.PROCESS_MODE_ALWAYS

	resume_button.pressed.connect(_on_resume_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	main_menu_button.pressed.connect(_on_main_menu_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

func _unhandled_input(event: InputEvent) -> void:
	# "ui_cancel" es la tecla Escape por defecto en Godot.
	if event.is_action_pressed("ui_cancel"):
		toggle_pause()

func toggle_pause() -> void:
	get_tree().paused = not get_tree().paused
	panel.visible = get_tree().paused

func _on_resume_pressed() -> void:
	toggle_pause()

func _on_settings_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(SETTINGS_SCENE_PATH)

func _on_main_menu_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(MAIN_MENU_SCENE_PATH)

func _on_quit_pressed() -> void:
	get_tree().quit()
