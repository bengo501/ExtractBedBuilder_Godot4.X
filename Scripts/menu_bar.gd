extends Control

@onready var file_menu = $HBoxContainer/FileMenu
@onready var edit_menu = $HBoxContainer/EditMenu
@onready var view_menu = $HBoxContainer/ViewMenu
@onready var tools_menu = $HBoxContainer/ToolsMenu
@onready var help_menu = $HBoxContainer/HelpMenu

var confirmation_dialog: ConfirmationDialog
var spawn_timer: Timer

# Sistema de histórico para desfazer/refazer
var action_history: Array = []
var current_action_index: int = -1
var max_history_size: int = 50  # Limite de ações no histórico

# Sistema de clipboard
var clipboard: Array = []  # Array para armazenar os objetos copiados
var spawner: Node  # Referência ao spawner

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
	# Criar diálogo de confirmação
	confirmation_dialog = ConfirmationDialog.new()
	confirmation_dialog.title = "Aviso"
	confirmation_dialog.dialog_text = "Você será redirecionado para uma página externa. Deseja continuar?"
	confirmation_dialog.confirmed.connect(_on_confirmation_dialog_confirmed)
	confirmation_dialog.size = Vector2(400, 150)  # Define um tamanho fixo para o diálogo
	confirmation_dialog.initial_position = Window.WINDOW_INITIAL_POSITION_CENTER_PRIMARY_SCREEN  # Centraliza na tela principal
	add_child(confirmation_dialog)
	
	# Criar timer para spawn
	spawn_timer = Timer.new()
	spawn_timer.one_shot = true
	add_child(spawn_timer)
	
	# Obter referência ao spawner
	spawner = get_node_or_null("/root/MainScene/ExtractionBed/Spawner")
	
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
	edit_popup.add_item("↩️ Desfazer", 0)
	edit_popup.add_item("↪️ Refazer", 1)
	edit_popup.add_separator()
	edit_popup.add_item("📋 Copiar", 2)
	edit_popup.add_item("📋 Colar", 3)
	edit_popup.id_pressed.connect(_on_edit_menu_id_pressed)
	
	# Configurar menu Visualizar
	var view_popup = view_menu.get_popup()
	view_popup.add_item("⬆️ Câmera Superior", 0)
	view_popup.add_item("➡️ Câmera Frontal", 1)
	view_popup.add_item("🎥 Câmera Livre", 2)
	view_popup.add_item("📐 Câmera Isométrica", 3)
	view_popup.add_separator()
	view_popup.add_item("📏 Mostrar Grade", 4)
	view_popup.add_item("📊 Mostrar Eixos", 5)
	view_popup.id_pressed.connect(_on_view_menu_id_pressed)
	
	# Configurar menu Ferramentas
	var tools_popup = tools_menu.get_popup()
	tools_popup.add_item("🔄 Resetar Câmeras", 0)
	tools_popup.add_item("🔄 Resetar Leito", 1)
	tools_popup.add_separator()
	tools_popup.add_item("🗑️ Limpar Objetos", 2)
	tools_popup.id_pressed.connect(_on_tools_menu_id_pressed)
	
	# Configurar menu Ajuda
	var help_popup = help_menu.get_popup()
	help_popup.add_item("📚 Documentação", 0)
	help_popup.add_item("ℹ️ Sobre", 1)
	help_popup.id_pressed.connect(_on_help_menu_id_pressed)

func _exit_tree():
	# Limpar timer ao sair
	if spawn_timer and is_instance_valid(spawn_timer):
		spawn_timer.queue_free()

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
			undo()
		1: # Refazer
			redo()
		2: # Copiar
			copy_objects()
		3: # Colar
			paste_objects()

func _on_view_menu_id_pressed(id: int):
	var camera_controller = get_node_or_null("/root/MainScene/CameraController")
	var grid_axes = get_node_or_null("/root/MainScene/GridAxes")
	
	match id:
		0: # Câmera Superior
			if camera_controller:
				camera_controller.current_camera_index = 3  # Top
				camera_controller._update_cameras()
		1: # Câmera Frontal
			if camera_controller:
				camera_controller.current_camera_index = 0  # Front
				camera_controller._update_cameras()
		2: # Câmera Livre
			if camera_controller:
				camera_controller.current_camera_index = 1  # Free
				camera_controller._update_cameras()
		3: # Câmera Isométrica
			if camera_controller:
				camera_controller.current_camera_index = 2  # Iso
				camera_controller._update_cameras()
		4: # Mostrar Grade
			if grid_axes:
				if grid_axes.grid_visible:
					grid_axes.hide_grid()
					print("Grade oculta")
				else:
					grid_axes.show_grid()
					print("Grade visível")
		5: # Mostrar Eixos
			if grid_axes:
				if grid_axes.axes_visible:
					grid_axes.hide_axes()
					print("Eixos ocultos")
				else:
					grid_axes.show_axes()
					print("Eixos visíveis")

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
