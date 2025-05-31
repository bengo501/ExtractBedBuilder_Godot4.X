extends Control

@onready var file_menu = $HBoxContainer/FileMenu
@onready var edit_menu = $HBoxContainer/EditMenu
@onready var view_menu = $HBoxContainer/ViewMenu
@onready var tools_menu = $HBoxContainer/ToolsMenu
@onready var help_menu = $HBoxContainer/HelpMenu

func _ready():
	# Configurar menu Arquivo
	var file_popup = file_menu.get_popup()
	file_popup.add_item("📂 Abrir", 0)
	file_popup.add_item("💾 Salvar Projeto", 1)
	file_popup.add_item("📤 Exportar Modelo", 2)
	file_popup.add_separator()
	file_popup.add_item("❌ Sair", 3)
	file_popup.id_pressed.connect(_on_file_menu_id_pressed)
	
	# Configurar menu Editar
	var edit_popup = edit_menu.get_popup()
	edit_popup.add_item("Desfazer", 0)
	edit_popup.add_item("Refazer", 1)
	edit_popup.add_separator()
	edit_popup.add_item("Copiar", 2)
	edit_popup.add_item("Colar", 3)
	edit_popup.id_pressed.connect(_on_edit_menu_id_pressed)
	
	# Configurar menu Visualizar
	var view_popup = view_menu.get_popup()
	view_popup.add_item("Câmera Superior", 0)
	view_popup.add_item("Câmera Frontal", 1)
	view_popup.add_item("Câmera Livre", 2)
	view_popup.add_item("Câmera Isométrica", 3)
	view_popup.add_separator()
	view_popup.add_item("Mostrar Grade", 4)
	view_popup.add_item("Mostrar Eixos", 5)
	view_popup.id_pressed.connect(_on_view_menu_id_pressed)
	
	# Configurar menu Ferramentas
	var tools_popup = tools_menu.get_popup()
	tools_popup.add_item("Resetar Câmeras", 0)
	tools_popup.add_item("Resetar Leito", 1)
	tools_popup.add_separator()
	tools_popup.add_item("Limpar Objetos", 2)
	tools_popup.id_pressed.connect(_on_tools_menu_id_pressed)
	
	# Configurar menu Ajuda
	var help_popup = help_menu.get_popup()
	help_popup.add_item("Documentação", 0)
	help_popup.add_item("Sobre", 1)
	help_popup.id_pressed.connect(_on_help_menu_id_pressed)

func _on_file_menu_id_pressed(id: int):
	match id:
		0: # Abrir
			print("Abrir arquivo (implementar)")
		1: # Salvar Projeto
			print("Salvar projeto (implementar)")
		2: # Exportar Modelo
			print("Exportar modelo (implementar)")
		3: # Sair
			get_tree().quit()

func _on_edit_menu_id_pressed(id: int):
	match id:
		0: # Desfazer
			print("Desfazer (implementar)")
		1: # Refazer
			print("Refazer (implementar)")
		2: # Copiar
			print("Copiar (implementar)")
		3: # Colar
			print("Colar (implementar)")

func _on_view_menu_id_pressed(id: int):
	var camera_controller = get_node("/root/MainScene/CameraController")
	if not camera_controller:
		return
		
	match id:
		0: # Câmera Superior
			camera_controller.switch_to_camera(0)
		1: # Câmera Frontal
			camera_controller.switch_to_camera(2)
		2: # Câmera Livre
			camera_controller.switch_to_camera(1)
		3: # Câmera Isométrica
			camera_controller.switch_to_camera(3)
		4: # Mostrar Grade
			print("Mostrar grade (implementar)")
		5: # Mostrar Eixos
			print("Mostrar eixos (implementar)")

func _on_tools_menu_id_pressed(id: int):
	match id:
		0: # Resetar Câmeras
			var camera_controller = get_node("/root/MainScene/CameraController")
			if camera_controller:
				camera_controller.reset_cameras()
		1: # Resetar Leito
			var extraction_bed = get_node("/root/MainScene/ExtractionBed")
			if extraction_bed:
				extraction_bed.reset_bed()
		2: # Limpar Objetos
			var spawner = get_node("/root/MainScene/ExtractionBed/Spawner")
			if spawner:
				spawner.clear_objects()

func _on_help_menu_id_pressed(id: int):
	match id:
		0: # Documentação
			print("Abrir documentação (implementar)")
		1: # Sobre
			print("Mostrar informações sobre o software (implementar)") 
