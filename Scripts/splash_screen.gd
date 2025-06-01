extends Control

@onready var loading_bar = $VBoxContainer/LoadingBar
@onready var loading_text = $VBoxContainer/LoadingText
@onready var animation_player = $AnimationPlayer

var language_manager: Node

func _ready():
	# Inicializar o gerenciador de idiomas
	language_manager = get_node("/root/LanguageManager")
	if not language_manager:
		language_manager = Node.new()
		language_manager.set_script(load("res://Scripts/language_manager.gd"))
		get_tree().root.add_child(language_manager)
	
	# Conectar ao sinal de mudança de idioma
	language_manager.connect("language_changed", Callable(self, "_on_language_changed"))
	
	# Iniciar animação
	animation_player.play("fade_in")
	
	# Iniciar carregamento
	await get_tree().create_timer(0.5).timeout
	_update_loading(0.2, language_manager.get_text("loading", "loading_resources"))
	
	await get_tree().create_timer(0.5).timeout
	_update_loading(0.4, language_manager.get_text("loading", "initializing"))
	
	await get_tree().create_timer(0.5).timeout
	_update_loading(0.6, language_manager.get_text("loading", "preparing"))
	
	await get_tree().create_timer(0.5).timeout
	_update_loading(0.8, language_manager.get_text("loading", "completed"))
	
	await get_tree().create_timer(0.5).timeout
	_update_loading(1.0, language_manager.get_text("loading", "completed"))
	
	# Aguardar um pouco antes de mudar de cena
	await get_tree().create_timer(0.5).timeout
	
	# Mudar para a cena principal
	get_tree().change_scene_to_file("res://Cenas/main_scene.tscn")

func _update_loading(progress: float, text: String):
	loading_bar.value = progress * 100
	loading_text.text = text

func _on_language_changed():
	# Atualizar textos quando o idioma mudar
	if loading_bar.value < 20:
		loading_text.text = language_manager.get_text("loading", "loading_resources")
	elif loading_bar.value < 40:
		loading_text.text = language_manager.get_text("loading", "initializing")
	elif loading_bar.value < 60:
		loading_text.text = language_manager.get_text("loading", "preparing")
	else:
		loading_text.text = language_manager.get_text("loading", "completed")
