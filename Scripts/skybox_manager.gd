extends Node

@export var world_environment_path: NodePath
@export var skybox_white_path: String = "res://Assets/Textures/AnyConv.com__sl_072622_51930_13.hdr"
@export var skybox_black_path: String = "res://Assets/Textures/AnyConv.com__SL-072622-51930-14.hdr"
@export var skybox_intensity: float = 0.1  # Valor inicial da intensidade do skybox

var world_environment: WorldEnvironment
var current_skybox: String = "white"

func _ready():
	world_environment = get_node(world_environment_path)

func toggle_skybox():
	if current_skybox == "white":
		load_skybox(skybox_black_path)
		current_skybox = "black"
	else:
		load_skybox(skybox_white_path)
		current_skybox = "white"

func load_skybox(skybox_path: String):
	var sky_material = PanoramaSkyMaterial.new()
	sky_material.panorama = load(skybox_path)
	sky_material.energy_multiplier = skybox_intensity  # Usa o valor de intensidade configurado
	
	var sky = Sky.new()
	sky.sky_material = sky_material
	
	world_environment.environment.background_mode = Environment.BG_SKY
	world_environment.environment.sky = sky 