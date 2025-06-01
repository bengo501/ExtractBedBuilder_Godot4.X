extends Control

@onready var loading_bar = $VBoxContainer/LoadingBar
@onready var loading_text = $VBoxContainer/LoadingText
@onready var animation_player = $AnimationPlayer

var loading_time: float = 2.0  # Tempo total de carregamento em segundos
var current_time: float = 0.0
var main_scene_path: String = "res://Cenas/main_scene.tscn"

func _ready():
	# Configurar animação de fade in
	var fade_in = Animation.new()
	var track_index = fade_in.add_track(Animation.TYPE_VALUE)
	fade_in.track_set_path(track_index, ".:modulate")
	fade_in.track_insert_key(track_index, 0.0, Color(1, 1, 1, 0.5))  # Começa com 50% de opacidade
	fade_in.track_insert_key(track_index, 0.2, Color(1, 1, 1, 1))    # Fade in mais rápido (0.2 segundos)
	
	# Configurar animação de fade out
	var fade_out = Animation.new()
	track_index = fade_out.add_track(Animation.TYPE_VALUE)
	fade_out.track_set_path(track_index, ".:modulate")
	fade_out.track_insert_key(track_index, 0.0, Color(1, 1, 1, 1))
	fade_out.track_insert_key(track_index, 0.5, Color(1, 1, 1, 0))
	
	# Criar biblioteca de animações
	var animation_library = AnimationLibrary.new()
	animation_library.add_animation("fade_in", fade_in)
	animation_library.add_animation("fade_out", fade_out)
	animation_player.add_animation_library("", animation_library)
	
	# Iniciar fade in
	animation_player.play("fade_in")
	
	# Iniciar carregamento
	loading_bar.value = 0
	loading_text.text = "Carregando..."

func _process(delta):
	if current_time < loading_time:
		current_time += delta
		var progress = (current_time / loading_time) * 100
		loading_bar.value = progress
		
		# Atualizar texto de carregamento
		if progress < 30:
			loading_text.text = "Carregando recursos..."
		elif progress < 60:
			loading_text.text = "Inicializando sistema..."
		elif progress < 90:
			loading_text.text = "Preparando interface..."
		else:
			loading_text.text = "Concluído!"
		
		# Quando terminar o carregamento
		if current_time >= loading_time:
			# Iniciar fade out
			animation_player.play("fade_out")
			# Aguardar a animação terminar antes de mudar de cena
			await animation_player.animation_finished
			# Carregar a cena principal
			get_tree().change_scene_to_file(main_scene_path) 
