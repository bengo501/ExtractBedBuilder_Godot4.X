extends Control

@onready var file_menu = $HBoxContainer/FileMenu
@onready var edit_menu = $HBoxContainer/EditMenu
@onready var view_menu = $HBoxContainer/ViewMenu
@onready var tools_menu = $HBoxContainer/ToolsMenu
@onready var help_menu = $HBoxContainer/HelpMenu
@onready var language_menu = $HBoxContainer/LanguageMenu

var confirmation_dialog: ConfirmationDialog
var spawn_timer: Timer
var language_manager: Node
var model_exporter: Node
var file_dialog: FileDialog
var export_dialog: AcceptDialog
var convert_button: Button
var export_button: Button

# Sistema de histórico para desfazer/refazer
var action_history: Array = []
var current_action_index: int = -1
var max_history_size: int = 50  # Limite de ações no histórico

# Sistema de clipboard
var clipboard: Array = []  # Array para armazenar os objetos copiados
var spawner: Node  # Referência ao spawner

# Referências aos painéis de controle
var ui_control_panel: Window
var spawner_control_panel: Window
var camera_info: Window
var bed_info: Window
var object_info: Window

# Estrutura para armazenar ações
class Action:
	var type: String  # Tipo da ação (ex: "move", "rotate", "delete", etc)
	var data: Dictionary  # Dados específicos da ação
	var timestamp: float  # Momento em que a ação foi realizada
	
	func _init(action_type: String, action_data: Dictionary):
		type = action_type
		data = action_data
		timestamp = Time.get_unix_time_from_system()

func _ready():
	# Aguardar um frame para garantir que todos os nós estejam prontos
	await get_tree().process_frame
	
	# Inicializar o gerenciador de idiomas
	language_manager = get_node("/root/LanguageManager")
	if not language_manager:
		push_error("MenuBar: LanguageManager não encontrado!")
		return
	
	# Inicializar o exportador de modelos
	model_exporter = Node.new()
	model_exporter.set_script(load("res://Scripts/model_exporter.gd"))
	add_child(model_exporter)
	model_exporter.export_complete.connect(_on_export_complete)
	
	# Criar diálogo de arquivo
	file_dialog = FileDialog.new()
	file_dialog.title = "Salvar Modelo"
	file_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	file_dialog.add_filter("*.obj", "OBJ Files")
	file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	file_dialog.current_dir = "res://exports"  # Definir diretório padrão
	file_dialog.file_selected.connect(_on_file_dialog_file_selected)
	add_child(file_dialog)
	
	# Conectar ao sinal de mudança de idioma
	if not language_manager.is_connected("language_changed", Callable(self, "_on_language_changed")):
		language_manager.connect("language_changed", Callable(self, "_on_language_changed"))
	
	# Encontrar os painéis de controle
	ui_control_panel = get_node("../UIControlPanel")
	spawner_control_panel = get_node("../UIControlPanel/SpawnerControlPanel")
	camera_info = get_node("../CameraInfo")
	bed_info = get_node("../BedInfo")
	object_info = get_node("../ObjectInfo")
	
	# Criar diálogo de confirmação
	confirmation_dialog = ConfirmationDialog.new()
	confirmation_dialog.title = "Aviso"
	confirmation_dialog.dialog_text = "Você será redirecionado para uma página externa. Deseja continuar?"
	confirmation_dialog.confirmed.connect(_on_confirmation_dialog_confirmed)
	confirmation_dialog.size = Vector2(400, 150)
	confirmation_dialog.initial_position = Window.WINDOW_INITIAL_POSITION_CENTER_PRIMARY_SCREEN
	add_child(confirmation_dialog)
	
	# Criar timer para spawn
	spawn_timer = Timer.new()
	spawn_timer.one_shot = true
	add_child(spawn_timer)
	
	# Obter referência ao spawner
	spawner = get_node_or_null("/root/MainScene/ExtractionBed/Spawner")
	
	# Verificar se todos os menus foram encontrados
	if not _verify_menu_nodes():
		push_error("Alguns nós do menu não foram encontrados!")
		return
	
	# Configurar menus
	_setup_menus()
	
	# Atualizar textos iniciais
	_update_menu_texts()
	
	# Adiciona diálogo de exportação
	export_dialog = AcceptDialog.new()
	export_dialog.dialog_text = "Exportação de Modelo 3D"
	convert_button = Button.new()
	convert_button.text = "Converter CSGs para MeshInstance3D"
	convert_button.pressed.connect(_on_convert_csgs_pressed)
	export_dialog.add_child(convert_button)
	export_button = Button.new()
	export_button.text = "Exportar para OBJ"
	export_button.disabled = true
	export_button.pressed.connect(_on_export_obj_pressed)
	export_dialog.add_child(export_button)
	add_child(export_dialog)

func _verify_menu_nodes() -> bool:
	if not file_menu or not edit_menu or not view_menu or not tools_menu or not help_menu or not language_menu:
		return false
	return true

func _setup_menus():
	# Configurar menu de arquivo
	var file_popup = file_menu.get_popup()
	file_popup.clear()
	file_popup.add_item(language_manager.get_text("file_menu", "open"), 0)
	file_popup.add_item(language_manager.get_text("file_menu", "save"), 1)
	file_popup.add_item(language_manager.get_text("file_menu", "export"), 2)
	file_popup.add_separator()
	file_popup.add_item(language_manager.get_text("file_menu", "exit"), 3)
	
	# Configurar menu de edição
	var edit_popup = edit_menu.get_popup()
	edit_popup.clear()
	edit_popup.add_item(language_manager.get_text("edit_menu", "undo"), 0)
	edit_popup.add_item(language_manager.get_text("edit_menu", "redo"), 1)
	edit_popup.add_separator()
	edit_popup.add_item(language_manager.get_text("edit_menu", "copy"), 2)
	edit_popup.add_item(language_manager.get_text("edit_menu", "paste"), 3)
	
	# Configurar menu de visualização
	var view_popup = view_menu.get_popup()
	view_popup.clear()
	view_popup.add_item(language_manager.get_text("menu_bar", "control_panel"), 0)
	view_popup.add_item(language_manager.get_text("menu_bar", "spawner_panel"), 1)
	view_popup.add_separator()
	view_popup.add_item("Informações da Câmera", 2)
	view_popup.add_item("Informações do Leito", 3)
	view_popup.add_item("Informações dos Objetos", 4)
	view_popup.add_separator()
	view_popup.add_item(language_manager.get_text("menu_bar", "grid"), 5)
	view_popup.add_item(language_manager.get_text("menu_bar", "axes"), 6)
	
	# Configurar menu de ferramentas
	var tools_popup = tools_menu.get_popup()
	tools_popup.clear()
	tools_popup.add_item(language_manager.get_text("tools_menu", "reset_cameras"), 0)
	tools_popup.add_item(language_manager.get_text("tools_menu", "reset_bed"), 1)
	tools_popup.add_separator()
	tools_popup.add_item(language_manager.get_text("tools_menu", "clear_objects"), 2)
	
	# Configurar menu de ajuda
	var help_popup = help_menu.get_popup()
	help_popup.clear()
	help_popup.add_item(language_manager.get_text("help_menu", "docs"), 0)
	help_popup.add_item(language_manager.get_text("help_menu", "about"), 1)
	
	# Configurar menu de idioma
	var language_popup = language_menu.get_popup()
	language_popup.clear()
	language_popup.add_item(language_manager.get_text("language_menu", "portuguese"), 0)
	language_popup.add_item(language_manager.get_text("language_menu", "english"), 1)
	
	# Conectar sinais
	file_popup.connect("id_pressed", Callable(self, "_on_file_menu_id_pressed"))
	edit_popup.connect("id_pressed", Callable(self, "_on_edit_menu_id_pressed"))
	view_popup.connect("id_pressed", Callable(self, "_on_view_menu_id_pressed"))
	tools_popup.connect("id_pressed", Callable(self, "_on_tools_menu_id_pressed"))
	help_popup.connect("id_pressed", Callable(self, "_on_help_menu_id_pressed"))
	language_popup.connect("id_pressed", Callable(self, "_on_language_menu_id_pressed"))

func _update_menu_texts():
	# Atualizar textos do menu de arquivo
	file_menu.text = "📁 " + language_manager.get_text("file_menu", "title")
	var file_popup = file_menu.get_popup()
	file_popup.set_item_text(0, language_manager.get_text("file_menu", "open"))
	file_popup.set_item_text(1, language_manager.get_text("file_menu", "save"))
	file_popup.set_item_text(2, language_manager.get_text("file_menu", "export"))
	file_popup.set_item_text(4, language_manager.get_text("file_menu", "exit"))
	
	# Atualizar textos do menu de edição
	edit_menu.text = "✏️ " + language_manager.get_text("edit_menu", "title")
	var edit_popup = edit_menu.get_popup()
	edit_popup.set_item_text(0, language_manager.get_text("edit_menu", "undo"))
	edit_popup.set_item_text(1, language_manager.get_text("edit_menu", "redo"))
	edit_popup.set_item_text(3, language_manager.get_text("edit_menu", "copy"))
	edit_popup.set_item_text(4, language_manager.get_text("edit_menu", "paste"))
	
	# Atualizar textos do menu de visualização
	view_menu.text = "👁️ " + language_manager.get_text("view_menu", "title")
	var view_popup = view_menu.get_popup()
	view_popup.set_item_text(0, language_manager.get_text("menu_bar", "control_panel"))
	view_popup.set_item_text(1, language_manager.get_text("menu_bar", "spawner_panel"))
	view_popup.set_item_text(2, language_manager.get_text("menu_bar", "grid"))
	view_popup.set_item_text(3, language_manager.get_text("menu_bar", "axes"))
	
	# Atualizar textos do menu de ferramentas
	tools_menu.text = "🛠️ " + language_manager.get_text("tools_menu", "title")
	var tools_popup = tools_menu.get_popup()
	tools_popup.set_item_text(0, language_manager.get_text("tools_menu", "reset_cameras"))
	tools_popup.set_item_text(1, language_manager.get_text("tools_menu", "reset_bed"))
	tools_popup.set_item_text(3, language_manager.get_text("tools_menu", "clear_objects"))
	
	# Atualizar textos do menu de ajuda
	help_menu.text = "❓ " + language_manager.get_text("help_menu", "title")
	var help_popup = help_menu.get_popup()
	help_popup.set_item_text(0, language_manager.get_text("help_menu", "docs"))
	help_popup.set_item_text(1, language_manager.get_text("help_menu", "about"))
	
	# Atualizar textos do menu de idioma
	language_menu.text = "🌐 " + language_manager.get_text("language_menu", "title")
	var language_popup = language_menu.get_popup()
	language_popup.set_item_text(0, language_manager.get_text("language_menu", "portuguese"))
	language_popup.set_item_text(1, language_manager.get_text("language_menu", "english"))

func _on_language_changed():
	print("MenuBar: Recebido sinal language_changed")
	_update_menu_texts()

func _on_language_menu_id_pressed(id: int):
	print("MenuBar: Menu de idioma pressionado - ID: ", id)
	match id:
		0: # Português
			language_manager.set_language("pt")
		1: # English
			language_manager.set_language("en")

func _exit_tree():
	# Limpar timer ao sair
	if spawn_timer and is_instance_valid(spawn_timer):
		spawn_timer.queue_free()

func _on_file_menu_id_pressed(id: int):
	match id:
		0: # Abrir
			print("Abrir arquivo (implementar)")
		1: # Salvar
			print("Salvar projeto (implementar)")
		2: # Exportar
			_export_model()
		3: # Sair
			get_tree().quit()

func _on_edit_menu_id_pressed(id: int):
	match id:
		0: # Desfazer
			undo()
		1: # Refazer
			redo()
		2: # Copiar
			copy_objects()
		3: # Colar
			paste_objects()

func _on_view_menu_id_pressed(id: int):
	match id:
		0:  # Control Panel
			ui_control_panel.show()
		1:  # Spawner Panel
			spawner_control_panel.show()
		2:  # Camera Info
			camera_info.show()
		3:  # Bed Info
			bed_info.show()
		4:  # Object Info
			object_info.show()
		5:  # Grid
			var grid_axes = get_node("../GridAxes")
			if grid_axes:
				grid_axes.toggle_grid()
		6:  # Axes
			var grid_axes = get_node("../GridAxes")
			if grid_axes:
				grid_axes.toggle_axes()

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
			confirmation_dialog.dialog_text = "Você será redirecionado para a documentação do projeto no GitHub. Deseja continuar?"
			confirmation_dialog.show()
		1: # Sobre
			confirmation_dialog.dialog_text = "Você será redirecionado para a página do projeto no GitHub. Deseja continuar?"
			confirmation_dialog.show()

func _on_confirmation_dialog_confirmed():
	# Verifica qual botão foi clicado baseado no texto do diálogo
	if confirmation_dialog.dialog_text.contains("documentação"):
		OS.shell_open("https://github.com/joxtto/LeitoExtra-oGodot")
	elif confirmation_dialog.dialog_text.contains("GitHub"):
		OS.shell_open("https://github.com/joxtto/LeitoExtra-oGodot")

# Função para adicionar uma nova ação ao histórico
func add_action(action_type: String, action_data: Dictionary):
	# Se estamos no meio do histórico, remove todas as ações futuras
	if current_action_index < action_history.size() - 1:
		action_history = action_history.slice(0, current_action_index + 1)
	
	# Cria e adiciona a nova ação
	var new_action = Action.new(action_type, action_data)
	action_history.append(new_action)
	current_action_index = action_history.size() - 1
	
	# Limita o tamanho do histórico
	if action_history.size() > max_history_size:
		action_history.pop_front()
		current_action_index -= 1
	
	# Atualiza o estado dos botões de desfazer/refazer
	_update_undo_redo_buttons()

# Função para desfazer a última ação
func undo():
	if current_action_index >= 0:
		var action = action_history[current_action_index]
		_execute_undo_action(action)
		current_action_index -= 1
		_update_undo_redo_buttons()

# Função para refazer a última ação desfeita
func redo():
	if current_action_index < action_history.size() - 1:
		current_action_index += 1
		var action = action_history[current_action_index]
		_execute_redo_action(action)
		_update_undo_redo_buttons()

# Função para executar a ação de desfazer
func _execute_undo_action(action: Action):
	match action.type:
		"paste":
			# Remover os objetos que foram colados
			if spawner:
				var children = spawner.get_children()
				for i in range(clipboard.size()):
					if i < children.size() and children[i].name != "SpawnerBlock":
						children[i].queue_free()
		"move":
			# Implementar lógica de desfazer movimento
			pass
		"rotate":
			# Implementar lógica de desfazer rotação
			pass
		"delete":
			# Implementar lógica de desfazer deleção
			pass

# Função para executar a ação de refazer
func _execute_redo_action(action: Action):
	match action.type:
		"paste":
			# Colar os objetos novamente
			paste_objects()
		"move":
			# Implementar lógica de refazer movimento
			pass
		"rotate":
			# Implementar lógica de refazer rotação
			pass
		"delete":
			# Implementar lógica de refazer deleção
			pass

# Função para atualizar o estado dos botões de desfazer/refazer
func _update_undo_redo_buttons():
	var edit_popup = edit_menu.get_popup()
	
	# Atualiza o estado do botão Desfazer
	edit_popup.set_item_disabled(0, current_action_index < 0)
	
	# Atualiza o estado do botão Refazer
	edit_popup.set_item_disabled(1, current_action_index >= action_history.size() - 1)

# Exemplo de como registrar uma ação
func _on_object_moved(object, old_position, new_position):
	var action_data = {
		"object": object,
		"old_position": old_position,
		"new_position": new_position
	}
	add_action("move", action_data)

# Exemplo de como registrar uma rotação
func _on_object_rotated(object, old_rotation, new_rotation):
	var action_data = {
		"object": object,
		"old_rotation": old_rotation,
		"new_rotation": new_rotation
	}
	add_action("rotate", action_data)

# Exemplo de como registrar uma deleção
func _on_object_deleted(object, position, rotation):
	var action_data = {
		"object": object,
		"position": position,
		"rotation": rotation
	}
	add_action("delete", action_data)

func _input(event):
	# Verificar atalhos de teclado para copiar/colar
	if event is InputEventKey:
		if event.pressed:
			if event.keycode == KEY_C and event.ctrl_pressed:
				copy_objects()
			elif event.keycode == KEY_V and event.ctrl_pressed:
				paste_objects()

# Função para copiar objetos
func copy_objects():
	if not spawner:
		return
	
	clipboard.clear()
	
	# Coletar informações de todos os objetos spawnados
	for child in spawner.get_children():
		# Verificar se é um nó 3D e não é o SpawnerBlock
		if child is Node3D and child.name != "SpawnerBlock":
			var object_data = {
				"type": child.get_meta("object_type", ""),  # Tipo do objeto (cubo, esfera, etc)
				"position": child.position,  # Usar position local em vez de global
				"rotation": child.rotation,  # Usar rotation local em vez de global
				"scale": child.scale
			}
			
			# Adicionar propriedades físicas apenas se o objeto for um RigidBody3D
			if child is RigidBody3D:
				object_data["properties"] = {
					"mass": child.mass,
					"linear_damp": child.linear_damp,
					"angular_damp": child.angular_damp,
					"gravity_scale": child.gravity_scale
				}
			
			clipboard.append(object_data)
	
	print("Objetos copiados: ", clipboard.size())

# Função para colar objetos
func paste_objects():
	if not spawner or clipboard.is_empty():
		return
	
	# Adicionar ação ao histórico
	var action_data = {
		"objects": clipboard.duplicate(true)
	}
	add_action("paste", action_data)
	
	# Spawnar cada objeto do clipboard
	for object_data in clipboard:
		# Criar o objeto usando o spawner com todos os parâmetros necessários
		var new_object = spawner.spawn_object(
			object_data.type,  # tipo do objeto
			object_data.scale.x,  # raio
			object_data.scale.y,  # altura
			object_data.scale.z,  # largura
			object_data.properties.get("mass", 1.0),  # massa
			object_data.properties.get("gravity_scale", 1.0),  # escala da gravidade
			object_data.properties.get("linear_damp", 0.1),  # amortecimento linear
			object_data.properties.get("angular_damp", 0.1)  # amortecimento angular
		)
		if new_object and new_object is Node3D:
			# Aplicar as propriedades básicas
			new_object.position = object_data.position
			new_object.rotation = object_data.rotation
			new_object.scale = object_data.scale
	
	print("Objetos colados: ", clipboard.size())

func _export_model():
	print("[MenuBar] Iniciando exportação de modelo...")
	file_dialog.popup_centered()

func _on_convert_csgs_pressed():
	_convert_all_csgs_to_mesh()
	export_button.disabled = false

func _on_export_obj_pressed():
	model_exporter.export_model("obj", "user://exported_model.obj")
	export_dialog.hide()

func _convert_all_csgs_to_mesh():
	var nodes = []
	# Leito e tampas
	var extraction_bed = get_node("/root/MainScene/ExtractionBed")
	if extraction_bed:
		nodes += extraction_bed.get_children()
	# Objetos spawnados
	var spawner = get_node("/root/MainScene/ExtractionBed/Spawner")
	if spawner:
		nodes += spawner.get_children()
	for node in nodes:
		if node is CSGShape3D:
			# Evita duplicar se já existe um MeshInstance3D com o mesmo nome
			var mesh_name = "Mesh_" + node.name
			if node.get_parent().has_node(mesh_name):
				continue
			var mesh_instance = _csg_to_mesh_instance(node)
			mesh_instance.name = mesh_name
			node.get_parent().add_child(mesh_instance)
			mesh_instance.owner = get_tree().get_edited_scene_root()
			mesh_instance.global_transform = node.global_transform

func _csg_to_mesh_instance(csg: CSGShape3D) -> MeshInstance3D:
	var orig_mesh : Mesh = csg.get_meshes()[1]
	var new_mesh : Mesh
	for i in orig_mesh.get_surface_count():
		var st = SurfaceTool.new()
		st.append_from(orig_mesh, i, Transform3D())
		st.set_material(orig_mesh.surface_get_material(i))
		st.index()
		if i == 0: new_mesh = st.commit()
		else: st.commit(new_mesh)
	var mesh_instance = MeshInstance3D.new()
	mesh_instance.mesh = new_mesh
	mesh_instance.global_transform = csg.global_transform
	return mesh_instance

func _on_file_dialog_file_selected(path: String):
	print("[MenuBar] Arquivo selecionado:", path)
	var selected_object = get_selected_object()
	if not selected_object:
		print("[MenuBar] Nenhum objeto selecionado!")
		return
	
	var save_path = path.get_base_dir()
	var file_name = path.get_file().get_basename()
	
	print("[MenuBar] Exportando objeto:", selected_object.name)
	print("[MenuBar] Caminho de salvamento:", save_path)
	print("[MenuBar] Nome do arquivo:", file_name)
	
	model_exporter.export_mesh_to_file(selected_object, save_path, file_name)

func _on_export_complete(success: bool, message: String):
	print("[MenuBar] Exportação concluída. Sucesso:", success)
	print("[MenuBar] Mensagem:", message)
	if success:
		OS.alert(message, "Sucesso")
	else:
		OS.alert(message, "Erro")

func get_selected_object() -> Node3D:
	# Implementar lógica para obter o objeto selecionado
	# Por enquanto, retorna o primeiro objeto encontrado
	var objects = get_tree().get_nodes_in_group("spawned_objects")
	if objects.size() > 0:
		return objects[0]
	return null 
