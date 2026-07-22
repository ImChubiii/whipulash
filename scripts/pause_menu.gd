extends Control
class_name PauseMenu

@onready var resume_button: Button = $Panel/VBoxContainer/ResumeButton
@onready var settings_button: Button = $Panel/VBoxContainer/SettingsButton
@onready var restart_button: Button = $Panel/VBoxContainer/RestartButton
@onready var quit_button: Button = $Panel/VBoxContainer/QuitButton

# Im Editor auf den SettingsMenu-Node ziehen (Geschwister-Node im selben
# CanvasLayer, z.B. "../SettingsMenu").
@export var settings_menu_path: NodePath
var settings_menu: SettingsMenu

func _ready() -> void:
	# WICHTIG: Damit dieses Menü auch dann noch auf Klicks/Escape reagiert,
	# wenn das Spiel pausiert ist (get_tree().paused = true), muss der
	# Process Mode auf "Always" stehen — sonst friert das Menü mit ein.
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false

	if settings_menu_path != NodePath(""):
		settings_menu = get_node_or_null(settings_menu_path)

	if settings_menu:
		settings_menu.back_pressed.connect(_on_settings_back)
	else:
		push_warning("PauseMenu: settings_menu_path ist nicht gesetzt — Settings-Button bleibt ohne Funktion.")

	resume_button.pressed.connect(_on_resume_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	restart_button.pressed.connect(_on_restart_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

func _unhandled_input(event: InputEvent) -> void:
	# Läuft erst NACH SettingsMenu._input() — falls dort gerade ein Rebind
	# lief, wurde das Escape-Event schon dort konsumiert und taucht hier
	# gar nicht mehr auf. Kommt es hier an, ist also sicher: kein Rebind
	# aktiv, wir können normal zwischen den Zuständen wechseln.
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		if settings_menu and settings_menu.visible:
			# Im Settings-Untermenü führt Escape zurück zur Pause-Übersicht,
			# statt das Spiel direkt fortzusetzen.
			_on_settings_back()
		elif visible:
			_resume()
		else:
			_open_pause()
		get_viewport().set_input_as_handled()

func _open_pause() -> void:
	visible = true
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _resume() -> void:
	visible = false
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _on_resume_pressed() -> void:
	_resume()

func _on_settings_pressed() -> void:
	visible = false
	if settings_menu:
		settings_menu.open()

func _on_settings_back() -> void:
	if settings_menu:
		settings_menu.close()
	visible = true

func _on_restart_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_quit_pressed() -> void:
	get_tree().quit()
