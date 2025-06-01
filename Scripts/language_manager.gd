extends Node

signal language_changed

var current_language: String = "pt"
var translations: Dictionary = {
	"pt": {
		"file_menu": {
			"title": "Arquivo",
			"open": "📂 Abrir",
			"save": "💾 Salvar Projeto",
			"export": "📤 Exportar Modelo",
			"exit": "❌ Sair"
		},
		"edit_menu": {
			"title": "Editar",
			"undo": "↩️ Desfazer",
			"redo": "↪️ Refazer",
			"copy": "📋 Copiar",
			"paste": "📋 Colar"
		},
		"view_menu": {
			"title": "Visualizar",
			"top_camera": "⬆️ Câmera Superior",
			"front_camera": "➡️ Câmera Frontal",
			"free_camera": "🎥 Câmera Livre",
			"iso_camera": "📐 Câmera Isométrica",
			"show_grid": "📏 Mostrar Grade",
			"show_axes": "📊 Mostrar Eixos"
		},
		"tools_menu": {
			"title": "Ferramentas",
			"reset_cameras": "🔄 Resetar Câmeras",
			"reset_bed": "🔄 Resetar Leito",
			"clear_objects": "🗑️ Limpar Objetos"
		},
		"help_menu": {
			"title": "Ajuda",
			"docs": "📚 Documentação",
			"about": "ℹ️ Sobre"
		},
		"language_menu": {
			"title": "Idioma",
			"portuguese": "🇧🇷 Português",
			"english": "🇺🇸 English"
		},
		"loading": {
			"loading": "Carregando...",
			"loading_resources": "Carregando recursos...",
			"initializing": "Inicializando sistema...",
			"preparing": "Preparando interface...",
			"completed": "Concluído!"
		},
		"object_info": {
			"title": "Informações do Objeto",
			"type": "Tipo",
			"position": "Posição",
			"rotation": "Rotação",
			"scale": "Escala",
			"mass": "Massa",
			"gravity": "Gravidade",
			"linear_damp": "Amortecimento Linear",
			"angular_damp": "Amortecimento Angular",
			"cube": "Cubo",
			"sphere": "Esfera",
			"cylinder": "Cilindro",
			"cone": "Cone",
			"torus": "Toro",
			"x": "X",
			"y": "Y",
			"z": "Z"
		},
		"camera_info": {
			"title": "Informações da Câmera",
			"position": "Posição",
			"rotation": "Rotação",
			"fov": "Campo de Visão",
			"near": "Plano Próximo",
			"far": "Plano Distante",
			"current": "Câmera Atual",
			"free": "Livre",
			"front": "Frontal",
			"iso": "Isométrica",
			"top": "Superior",
			"x": "X",
			"y": "Y",
			"z": "Z",
			"degrees": "graus"
		},
		"bed_info": {
			"title": "Informações do Leito",
			"position": "Posição",
			"rotation": "Rotação",
			"scale": "Escala",
			"dimensions": "Dimensões",
			"width": "Largura",
			"length": "Comprimento",
			"height": "Altura",
			"objects": "Objetos",
			"total": "Total",
			"x": "X",
			"y": "Y",
			"z": "Z",
			"degrees": "graus",
			"meters": "metros"
		},
		"ui_control_panel": {
			"floor_distance": "Distância do Chão (cm)",
			"zoom": "Zoom",
			"height": "Altura (cm)",
			"width": "Largura (cm)",
			"diameter": "Diâmetro (cm)",
			"inner_radius": "Raio do Espaço Interno (cm)",
			"outline": "Outline",
			"transparency": "Transparência",
			"color": "Cor",
			"bed_caps": "Tampas do Leito",
			"add_lower_cap": "Adicionar Tampa Inferior",
			"remove_lower_cap": "Remover Tampa Inferior",
			"add_upper_cap": "Adicionar Tampa Superior",
			"remove_upper_cap": "Remover Tampa Superior",
			"reset_bed": "Resetar Leito",
			"black_grid": "Grid Preta",
			"skybox_intensity": "Intensidade do Skybox"
		},
		"spawner_control_panel": {
			"spawner_height": "Altura do Spawner (cm):",
			"object_type": "Tipo de Objeto",
			"quantity": "Quantidade",
			"radius": "Raio/Diâmetro (cm)",
			"height": "Altura (cm)",
			"width": "Largura (cm)",
			"interval": "Intervalo (s)",
			"start_spawn": "Iniciar Spawn",
			"clear_objects": "Limpar Objetos",
			"physics_properties": "Propriedades Físicas",
			"mass": "Massa",
			"gravity_scale": "Escala da Gravidade",
			"linear_damp": "Amortecimento Linear",
			"angular_damp": "Amortecimento Angular"
		}
	},
	"en": {
		"file_menu": {
			"title": "File",
			"open": "📂 Open",
			"save": "💾 Save Project",
			"export": "📤 Export Model",
			"exit": "❌ Exit"
		},
		"edit_menu": {
			"title": "Edit",
			"undo": "↩️ Undo",
			"redo": "↪️ Redo",
			"copy": "📋 Copy",
			"paste": "📋 Paste"
		},
		"view_menu": {
			"title": "View",
			"top_camera": "⬆️ Top Camera",
			"front_camera": "➡️ Front Camera",
			"free_camera": "🎥 Free Camera",
			"iso_camera": "📐 Isometric Camera",
			"show_grid": "📏 Show Grid",
			"show_axes": "📊 Show Axes"
		},
		"tools_menu": {
			"title": "Tools",
			"reset_cameras": "🔄 Reset Cameras",
			"reset_bed": "🔄 Reset Bed",
			"clear_objects": "🗑️ Clear Objects"
		},
		"help_menu": {
			"title": "Help",
			"docs": "📚 Documentation",
			"about": "ℹ️ About"
		},
		"language_menu": {
			"title": "Language",
			"portuguese": "🇧🇷 Portuguese",
			"english": "🇺🇸 English"
		},
		"loading": {
			"loading": "Loading...",
			"loading_resources": "Loading resources...",
			"initializing": "Initializing system...",
			"preparing": "Preparing interface...",
			"completed": "Completed!"
		},
		"object_info": {
			"title": "Object Information",
			"type": "Type",
			"position": "Position",
			"rotation": "Rotation",
			"scale": "Scale",
			"mass": "Mass",
			"gravity": "Gravity",
			"linear_damp": "Linear Damping",
			"angular_damp": "Angular Damping",
			"cube": "Cube",
			"sphere": "Sphere",
			"cylinder": "Cylinder",
			"cone": "Cone",
			"torus": "Torus",
			"x": "X",
			"y": "Y",
			"z": "Z"
		},
		"camera_info": {
			"title": "Camera Information",
			"position": "Position",
			"rotation": "Rotation",
			"fov": "Field of View",
			"near": "Near Plane",
			"far": "Far Plane",
			"current": "Current Camera",
			"free": "Free",
			"front": "Front",
			"iso": "Isometric",
			"top": "Top",
			"x": "X",
			"y": "Y",
			"z": "Z",
			"degrees": "degrees"
		},
		"bed_info": {
			"title": "Bed Information",
			"position": "Position",
			"rotation": "Rotation",
			"scale": "Scale",
			"dimensions": "Dimensions",
			"width": "Width",
			"length": "Length",
			"height": "Height",
			"objects": "Objects",
			"total": "Total",
			"x": "X",
			"y": "Y",
			"z": "Z",
			"degrees": "degrees",
			"meters": "meters"
		},
		"ui_control_panel": {
			"floor_distance": "Floor Distance (cm)",
			"zoom": "Zoom",
			"height": "Height (cm)",
			"width": "Width (cm)",
			"diameter": "Diameter (cm)",
			"inner_radius": "Inner Space Radius (cm)",
			"outline": "Outline",
			"transparency": "Transparency",
			"color": "Color",
			"bed_caps": "Bed Caps",
			"add_lower_cap": "Add Lower Cap",
			"remove_lower_cap": "Remove Lower Cap",
			"add_upper_cap": "Add Upper Cap",
			"remove_upper_cap": "Remove Upper Cap",
			"reset_bed": "Reset Bed",
			"black_grid": "Black Grid",
			"skybox_intensity": "Skybox Intensity"
		},
		"spawner_control_panel": {
			"spawner_height": "Spawner Height (cm):",
			"object_type": "Object Type",
			"quantity": "Quantity",
			"radius": "Radius/Diameter (cm)",
			"height": "Height (cm)",
			"width": "Width (cm)",
			"interval": "Interval (s)",
			"start_spawn": "Start Spawn",
			"clear_objects": "Clear Objects",
			"physics_properties": "Physics Properties",
			"mass": "Mass",
			"gravity_scale": "Gravity Scale",
			"linear_damp": "Linear Damping",
			"angular_damp": "Angular Damping"
		}
	}
}

func _ready():
	print("LanguageManager: Inicializando...")
	# Carregar idioma salvo
	var saved_language = load_language()
	if saved_language:
		current_language = saved_language
		print("LanguageManager: Idioma carregado: ", current_language)
		emit_signal("language_changed")
	else:
		print("LanguageManager: Usando idioma padrão: ", current_language)

func get_text(category: String, key: String) -> String:
	if translations.has(current_language) and translations[current_language].has(category):
		var category_dict = translations[current_language][category]
		if category_dict.has(key):
			var text = category_dict[key]
			print("LanguageManager: Obtendo texto - Categoria: ", category, ", Chave: ", key, ", Texto: ", text)
			return text
	print("LanguageManager: Texto não encontrado - Categoria: ", category, ", Chave: ", key)
	return key

func set_language(lang: String):
	if translations.has(lang):
		print("LanguageManager: Alterando idioma de ", current_language, " para ", lang)
		current_language = lang
		save_language(lang)
		print("LanguageManager: Emitindo sinal language_changed")
		emit_signal("language_changed")
	else:
		print("LanguageManager: Idioma inválido: ", lang)

func save_language(lang: String):
	var config = ConfigFile.new()
	config.set_value("language", "current", lang)
	var err = config.save("user://language.cfg")
	if err == OK:
		print("LanguageManager: Idioma salvo com sucesso: ", lang)
	else:
		print("LanguageManager: Erro ao salvar idioma: ", err)

func load_language() -> String:
	var config = ConfigFile.new()
	var err = config.load("user://language.cfg")
	if err == OK:
		var lang = config.get_value("language", "current", "pt")
		print("LanguageManager: Idioma carregado do arquivo: ", lang)
		return lang
	print("LanguageManager: Usando idioma padrão (pt)")
	return "pt" 