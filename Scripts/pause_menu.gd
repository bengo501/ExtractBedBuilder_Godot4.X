extends Control

@onready var resume_button = $CenterContainer/VBoxContainer/ResumeButton
@onready var save_button = $CenterContainer/VBoxContainer/SaveButton
@onready var export_button = $CenterContainer/VBoxContainer/ExportButton
@onready var restart_button = $CenterContainer/VBoxContainer/RestartButton
@onready var quit_button = $CenterContainer/VBoxContainer/QuitButton

func _ready():
	resume_button.pressed.connect(_on_resume_pressed)
	save_button.pressed.connect(_on_save_pressed)
	export_button.pressed.connect(_on_export_pressed)
	restart_button.pressed.connect(_on_restart_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	visible = false

func _unhandled_input(event):
	if event is InputEventKey and event.keycode == KEY_ESCAPE and event.pressed:
		toggle_menu()
		get_viewport().set_input_as_handled()

func open_menu():
	visible = true
	get_tree().paused = true
	process_mode = Node.PROCESS_MODE_ALWAYS

func close_menu():
	visible = false
	get_tree().paused = false
	process_mode = Node.PROCESS_MODE_INHERIT

func toggle_menu():
	if visible:
		close_menu()
	else:
		open_menu()

func _on_resume_pressed():
	close_menu()

func _on_save_pressed():
	# TODO: Implementar lógica de salvar projeto
	print("Salvar projeto (implementar)")
	# Não fecha o menu após salvar para permitir múltiplos salvamentos

func _on_export_pressed():
	# TODO: Implementar lógica de exportar modelo
	print("Exportar modelo (implementar)")
	# Não fecha o menu após exportar para permitir múltiplas exportações

func _on_restart_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_quit_pressed():
	get_tree().quit() 
