extends Control

# A dónde vuelve el botón "Volver". Si abres este menú desde la pausa,
# más abajo (PauseMenu.gd) se encarga de no romper la partida.
const MAIN_MENU_SCENE_PATH := "res://Scenes/UI/MainMenu.tscn"

@onready var volume_slider: HSlider = $CenterContainer/VBoxContainer/VolumeSlider
@onready var fullscreen_toggle: CheckButton = $CenterContainer/VBoxContainer/FullscreenToggle
@onready var back_button: Button = $CenterContainer/VBoxContainer/BackButton

func _ready() -> void:
	var master_bus := AudioServer.get_bus_index("Master")
	volume_slider.value = db_to_linear(AudioServer.get_bus_volume_db(master_bus))
	volume_slider.value_changed.connect(_on_volume_changed)

	fullscreen_toggle.button_pressed = (
		DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
	)
	fullscreen_toggle.toggled.connect(_on_fullscreen_toggled)

	back_button.pressed.connect(_on_back_pressed)

func _on_volume_changed(value: float) -> void:
	var master_bus := AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(master_bus, linear_to_db(value))

func _on_fullscreen_toggled(toggled_on: bool) -> void:
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file(MAIN_MENU_SCENE_PATH)
