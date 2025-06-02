extends Control

var language_manager: Node
var windows = []
var model_exporter: Node

@onready var title_label = $CenterContainer/VBoxContainer/Title
@onready var resume_button = $CenterContainer/VBoxContainer/ResumeButton
@onready var save_button = $CenterContainer/VBoxContainer/SaveButton
@onready var export_button = $CenterContainer/VBoxContainer/ExportButton
@onready var settings_button = $CenterContainer/VBoxContainer/SettingsButton
@onready var quit_button = $CenterContainer/VBoxContainer/QuitButton

func _ready():
	# Inicializar o gerenciador de idiomas
	language_manager = get_node("/root/LanguageManager")
	if not language_manager:
		push_error("PauseMenu: LanguageManager não encontrado!")
		return
	
	# Conectar ao sinal de mudança de idioma
	if not language_manager.is_connected("language_changed", Callable(self, "_on_language_changed")):
		language_manager.connect("language_changed", Callable(self, "_on_language_changed"))
	
	# Inicializar o exportador de modelos
	model_exporter = Node.new()
	model_exporter.set_script(load("res://Scripts/model_exporter.gd"))
	add_child(model_exporter)
	model_exporter.export_complete.connect(_on_export_complete)
	
	# Conectar sinais dos botões
	resume_button.pressed.connect(_on_resume_pressed)
	save_button.pressed.connect(_on_save_pressed)
	export_button.pressed.connect(_on_export_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	
	# Atualizar textos iniciais
	_update_labels()
	
	# Garantir que o menu começa invisível
	visible = false
	
	# Habilitar processamento de input
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Coletar todas as janelas
	windows = [
		get_node("../UIControlPanel"),
		get_node("../UIControlPanel/SpawnerControlPanel"),
		get_node("../CameraInfo"),
		get_node("../ObjectInfo"),
		get_node("../BedInfo")
	]

func _input(event):
	if event is InputEventKey and event.keycode == KEY_ESCAPE and event.pressed:
		toggle_menu()
		get_viewport().set_input_as_handled()

func toggle_menu():
	if visible:
		close_menu()
	else:
		open_menu()

func open_menu():
	visible = true
	get_tree().paused = true
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Esconder todas as janelas
	for window in windows:
		if window:
			window.hide()

func close_menu():
	visible = false
	get_tree().paused = false
	process_mode = Node.PROCESS_MODE_INHERIT
	
	# Mostrar todas as janelas
	for window in windows:
		if window:
			window.show()

func _update_labels():
	if not language_manager:
		return
		
	title_label.text = language_manager.get_text("pause_menu", "title")
	resume_button.text = language_manager.get_text("pause_menu", "resume")
	save_button.text = language_manager.get_text("pause_menu", "save")
	export_button.text = language_manager.get_text("pause_menu", "export")
	settings_button.text = language_manager.get_text("pause_menu", "settings")
	quit_button.text = language_manager.get_text("pause_menu", "quit")

func _on_language_changed():
	_update_labels()

func _on_resume_pressed():
	close_menu()

func _on_save_pressed():
	# TODO: Implementar lógica de salvar projeto
	print("Salvar projeto (implementar)")
	# Não fecha o menu após salvar para permitir múltiplos salvamentos

func _on_export_pressed():
	var dialog = FileDialog.new()
	dialog.title = "Exportar Modelo"
	dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	dialog.add_filter("*.obj", "OBJ Files")
	dialog.add_filter("*.stl", "STL Files")
	dialog.add_filter("*.fbx", "FBX Files")
	
	# Conectar o sinal de arquivo selecionado
	dialog.file_selected.connect(_on_export_file_selected)
	
	# Adicionar o diálogo à cena
	add_child(dialog)
	dialog.popup_centered()

func _on_export_file_selected(path: String):
	var format = path.get_extension().to_lower()
	model_exporter.export_model(format, path)

func _on_export_complete(success: bool, message: String):
	# Mostrar mensagem de sucesso/erro
	var dialog = AcceptDialog.new()
	dialog.title = "Exportação"
	dialog.dialog_text = message
	add_child(dialog)
	dialog.popup_centered()

func _on_settings_pressed():
	# Implementar lógica das configurações
	pass

func _on_quit_pressed():
	get_tree().quit() 
