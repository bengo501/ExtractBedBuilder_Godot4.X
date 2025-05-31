extends Control

@export var spawner_path: NodePath
var spawner: Node3D

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

func _ready():
	spawner = get_node(spawner_path)
	# Adiciona as opções ao OptionButton
	type_option.clear()
	type_option.add_item("Esfera")   # 0
	type_option.add_item("Cubo")     # 1
	type_option.add_item("Cilindro") # 2
	type_option.add_item("Plano")    # 3
	spawn_button.pressed.connect(_on_spawn_button_pressed)
	clear_button.pressed.connect(_on_clear_button_pressed)
	height_slider.value_changed.connect(_on_height_slider_changed)
	
	# Configura o slider de altura
	height_slider.min_value = 0.0
	height_slider.max_value = 10.0
	height_slider.value = 5.0  # Define a altura inicial como 5
	spawner.position.y = 5.0   # Define a posição inicial do spawner
	height_label.text = "Altura do Spawner: %.1f" % height_slider.value

func _on_height_slider_changed(value: float):
	spawner.position.y = value
	height_label.text = "Altura do Spawner: %.1f" % value

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
