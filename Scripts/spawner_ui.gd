extends Control

@export var spawner_path: NodePath
var spawner: Node3D

@onready var type_option: OptionButton = $SpawnerVBox/TypeOption
@onready var qtd_spin: SpinBox = $SpawnerVBox/QtdSpin
@onready var raio_spin: SpinBox = $SpawnerVBox/RaioSpin
@onready var altura_spin: SpinBox = $SpawnerVBox/AlturaSpin
@onready var largura_spin: SpinBox = $SpawnerVBox/LarguraSpin
@onready var intervalo_spin: SpinBox = $SpawnerVBox/IntervaloSpin
@onready var spawn_button: Button = $SpawnerVBox/SpawnButton

func _ready():
	spawner = get_node(spawner_path)
	spawn_button.pressed.connect(_on_spawn_button_pressed)

func _on_spawn_button_pressed():
	var type_map = {0: "sphere", 1: "cube", 2: "cylinder", 3: "plane"}
	var obj_type = type_map.get(type_option.selected, "sphere")
	var qtd = int(qtd_spin.value)
	var raio = float(raio_spin.value)
	var altura = float(altura_spin.value)
	var largura = float(largura_spin.value)
	var intervalo = float(intervalo_spin.value)
	spawner.start_spawning(qtd, obj_type, raio, altura, largura, intervalo) 
