extends Window

@export var spawner_path: NodePath
var spawner: Node3D
var language_manager: Node

@onready var type_option: OptionButton = $SpawnerVBox/TypeOption
@onready var qtd_spin: SpinBox = $SpawnerVBox/QtdSpin
@onready var raio_spin: SpinBox = $SpawnerVBox/RaioSpin
@onready var altura_spin: SpinBox = $SpawnerVBox/AlturaSpin
@onready var largura_spin: SpinBox = $SpawnerVBox/LarguraSpin
@onready var intervalo_spin: SpinBox = $SpawnerVBox/IntervaloSpin
@onready var mass_spin: SpinBox = $SpawnerVBox/MassSpin
@onready var gravity_scale_spin: SpinBox = $SpawnerVBox/GravityScaleSpin
@onready var linear_damp_spin: SpinBox = $SpawnerVBox/LinearDampSpin
@onready var angular_damp_spin: SpinBox = $SpawnerVBox/AngularDampSpin
@onready var spawn_button: Button = $SpawnerVBox/SpawnButton
@onready var clear_button: Button = $SpawnerVBox/ClearButton
@onready var height_slider: HSlider = $SpawnerVBox/HeightSlider
@onready var height_label: Label = $SpawnerVBox/HeightLabel
@onready var type_label: Label = $SpawnerVBox/TypeLabel
@onready var qtd_label: Label = $SpawnerVBox/QtdLabel
@onready var raio_label: Label = $SpawnerVBox/RaioLabel
@onready var altura_label: Label = $SpawnerVBox/AlturaLabel
@onready var largura_label: Label = $SpawnerVBox/LarguraLabel
@onready var intervalo_label: Label = $SpawnerVBox/IntervaloLabel
@onready var physics_label: Label = $SpawnerVBox/PhysicsLabel
@onready var mass_label: Label = $SpawnerVBox/MassLabel
@onready var gravity_scale_label: Label = $SpawnerVBox/GravityScaleLabel
@onready var linear_damp_label: Label = $SpawnerVBox/LinearDampLabel
@onready var angular_damp_label: Label = $SpawnerVBox/AngularDampLabel

func _ready():
	# Configurar a janela
	close_requested.connect(_on_close_requested)
	
	# Inicializar o gerenciador de idiomas
	language_manager = get_node("/root/LanguageManager")
	if not language_manager:
		push_error("SpawnerUI: LanguageManager não encontrado!")
		return
	
	# Conectar ao sinal de mudança de idioma
	if not language_manager.is_connected("language_changed", Callable(self, "_on_language_changed")):
		language_manager.connect("language_changed", Callable(self, "_on_language_changed"))
	
	spawner = get_node(spawner_path)
	# Adiciona as opções ao OptionButton
	type_option.clear()
	type_option.add_item(language_manager.get_text("object_info", "cube"))
	type_option.add_item(language_manager.get_text("object_info", "sphere"))
	type_option.add_item(language_manager.get_text("object_info", "cylinder"))
	type_option.add_item(language_manager.get_text("object_info", "plane"))
	spawn_button.pressed.connect(_on_spawn_button_pressed)
	clear_button.pressed.connect(_on_clear_button_pressed)
	height_slider.value_changed.connect(_on_height_slider_changed)
	
	# Configura o slider de altura
	height_slider.min_value = 0.0
	height_slider.max_value = 10.0
	height_slider.value = 5.0  # Define a altura inicial como 5
	spawner.position.y = 5.0   # Define a posição inicial do spawner
	height_label.text = language_manager.get_text("spawner_control_panel", "spawner_height") + " " + str(height_slider.value)

func _on_close_requested():
	hide()

func _on_height_slider_changed(value: float):
	spawner.position.y = value
	height_label.text = language_manager.get_text("spawner_control_panel", "spawner_height") + " " + str(value)

func _on_spawn_button_pressed():
	var type_map = {0: "sphere", 1: "cube", 2: "cylinder", 3: "plane"}
	var obj_type = type_map.get(type_option.selected, "sphere")
	var qtd = int(qtd_spin.value)
	var raio = float(raio_spin.value)
	var altura = float(altura_spin.value)
	var largura = float(largura_spin.value)
	var intervalo = float(intervalo_spin.value)
	var mass = float(mass_spin.value)
	var gravity_scale = float(gravity_scale_spin.value)
	var linear_damp = float(linear_damp_spin.value)
	var angular_damp = float(angular_damp_spin.value)
	spawner.start_spawning(qtd, obj_type, raio, altura, largura, intervalo, mass, gravity_scale, linear_damp, angular_damp)

func _on_clear_button_pressed():
	spawner.clear_objects() 

func _on_language_changed():
	_update_labels()

func _update_labels():
	if not language_manager:
		return
		
	height_label.text = language_manager.get_text("spawner_control_panel", "spawner_height") + " " + str(height_slider.value)
	type_label.text = language_manager.get_text("spawner_control_panel", "object_type")
	qtd_label.text = language_manager.get_text("spawner_control_panel", "quantity")
	raio_label.text = language_manager.get_text("spawner_control_panel", "radius")
	altura_label.text = language_manager.get_text("spawner_control_panel", "height")
	largura_label.text = language_manager.get_text("spawner_control_panel", "width")
	intervalo_label.text = language_manager.get_text("spawner_control_panel", "interval")
	spawn_button.text = language_manager.get_text("spawner_control_panel", "start_spawn")
	clear_button.text = language_manager.get_text("spawner_control_panel", "clear_objects")
	physics_label.text = language_manager.get_text("spawner_control_panel", "physics_properties")
	mass_label.text = language_manager.get_text("spawner_control_panel", "mass")
	gravity_scale_label.text = language_manager.get_text("spawner_control_panel", "gravity_scale")
	linear_damp_label.text = language_manager.get_text("spawner_control_panel", "linear_damp")
	angular_damp_label.text = language_manager.get_text("spawner_control_panel", "angular_damp")
	
	# Atualizar opções de tipo
	var selected_index = type_option.selected
	type_option.clear()
	type_option.add_item(language_manager.get_text("object_info", "cube"))
	type_option.add_item(language_manager.get_text("object_info", "sphere"))
	type_option.add_item(language_manager.get_text("object_info", "cylinder"))
	type_option.add_item(language_manager.get_text("object_info", "plane"))
	type_option.selected = selected_index

func _on_type_selected(index: int):
	_update_labels()

func _on_qtd_changed(value: float):
	_update_labels()

func _on_raio_changed(value: float):
	_update_labels()

func _on_altura_changed(value: float):
	_update_labels()

func _on_largura_changed(value: float):
	_update_labels()

func _on_intervalo_changed(value: float):
	_update_labels()

func _on_mass_changed(value: float):
	_update_labels()

func _on_gravity_scale_changed(value: float):
	_update_labels()

func _on_linear_damp_changed(value: float):
	_update_labels()

func _on_angular_damp_changed(value: float):
	_update_labels() 
