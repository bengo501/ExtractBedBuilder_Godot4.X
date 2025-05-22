extends Control

@onready var save_button = $Panel/VBoxContainer/SaveButton
@onready var restart_button = $Panel/VBoxContainer/RestartButton
@onready var quit_button = $Panel/VBoxContainer/QuitButton

func _ready():
	save_button.pressed.connect(_on_save_pressed)
	restart_button.pressed.connect(_on_restart_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	visible = false

	# Estilo visual do painel
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.13, 0.15, 0.18, 0.95)
	style.border_width_all = 3
	style.border_color = Color(0.0, 0.8, 1.0, 1.0)
	style.corner_radius_top_left = 24
	style.corner_radius_top_right = 24
	style.corner_radius_bottom_left = 24
	style.corner_radius_bottom_right = 24
	style.shadow_size = 16
	style.shadow_color = Color(0,0,0,0.4)
	$Panel.add_theme_stylebox("panel", style)

func _input(event):
	if event is InputEventKey and event.keycode == KEY_ESCAPE and event.pressed:
		toggle_menu()

func open_menu():
	visible = true
	get_tree().paused = true

func close_menu():
	visible = false
	get_tree().paused = false

func toggle_menu():
	if visible:
		close_menu()
	else:
		open_menu()

func _on_save_pressed():
	# TODO: Implementar lógica de salvar modelo
	print("Salvar modelo (implemente a lógica desejada)")
	# Exemplo: close_menu() após salvar

func _on_restart_pressed():
	get_tree().reload_current_scene()

func _on_quit_pressed():
	get_tree().quit() 