extends Node

@export var world_environment_path: NodePath
@export var skybox_white_path: String = "res://Assets/Textures/AnyConv.com__sl_072622_51930_13.hdr"
@export var skybox_black_path: String = "res://Assets/Textures/AnyConv.com__SL-072622-51930-14.hdr"
@export var skybox_intensity: float = 0.1  # Valor inicial da intensidade do skybox

var world_environment: WorldEnvironment
var current_skybox: String = "white"

func _ready():
	# Aguarda um frame para garantir que todos os nós estejam prontos
	await get_tree().process_frame
	
	if world_environment_path.is_empty():
		push_error("SkyboxManager: world_environment_path não está configurado!")
		return
		
	world_environment = get_node(world_environment_path)
	if not world_environment:
		push_error("SkyboxManager: WorldEnvironment não encontrado no caminho especificado!")
		return
		
	if not world_environment.environment:
		push_error("SkyboxManager: Environment não está configurado no WorldEnvironment!")
		return
		
	# Carrega o skybox inicial
	load_skybox(skybox_white_path)

func toggle_skybox():
	if not world_environment or not world_environment.environment:
		push_error("SkyboxManager: WorldEnvironment ou Environment não está disponível!")
		return
		
	if current_skybox == "white":
		load_skybox(skybox_black_path)
		current_skybox = "black"
	else:
		load_skybox(skybox_white_path)
		current_skybox = "white"

func load_skybox(skybox_path: String):
	if not world_environment or not world_environment.environment:
		push_error("SkyboxManager: WorldEnvironment ou Environment não está disponível!")
		return
		
	var sky_material = PanoramaSkyMaterial.new()
	sky_material.panorama = load(skybox_path)
	if not sky_material.panorama:
		push_error("SkyboxManager: Não foi possível carregar a textura do skybox: " + skybox_path)
		return
		
	sky_material.energy_multiplier = skybox_intensity
	
	var sky = Sky.new()
	sky.sky_material = sky_material
	
	world_environment.environment.background_mode = Environment.BG_SKY
	world_environment.environment.sky = sky 
