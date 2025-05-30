extends Node3D

signal bed_reset

# Valores iniciais do leito
const INITIAL_HEIGHT = 2.0
const INITIAL_WIDTH = 1.0
const INITIAL_DIAMETER = 1.0
const INITIAL_INNER_RADIUS = 0.4
const INITIAL_OUTLINE_COLOR = Color(0, 0.8, 1, 1)
const INITIAL_TRANSPARENCY = 0.3

@export var height: float = INITIAL_HEIGHT:
	set(value):
		height = value
		_update_bed()
		_update_tampas()

@export var width: float = INITIAL_WIDTH:
	set(value):
		width = value
		_update_bed()

@export var diameter: float = INITIAL_DIAMETER:
	set(value):
		diameter = value
		_update_bed()
		_update_tampas()

@export var inner_cylinder_radius: float = INITIAL_INNER_RADIUS:
	set(value):
		inner_cylinder_radius = value
		_update_bed()

@export var outline_color: Color = INITIAL_OUTLINE_COLOR:
	set(value):
		outline_color = value
		_update_materials()

@export var transparency: float = INITIAL_TRANSPARENCY:
	set(value):
		transparency = value
		_update_materials()

var tampa_inferior: CSGCylinder3D
var tampa_superior: CSGCylinder3D
var main_cylinder: CSGCylinder3D
var inner_cylinder: CSGCylinder3D

# Constantes para o posicionamento
const FLOOR_Y = 0.0  # Posição Y do chão
const MIN_DISTANCE_FROM_FLOOR = 0.1  # Distância mínima do chão
const MIN_DISTANCE_FROM_BED = 0.001  # Distância mínima do leito
const MAX_HEIGHT = 10.0  # Altura máxima permitida

func _ready():
	main_cylinder = $CSGCylinder3D
	inner_cylinder = $CSGCylinder3D/InnerCylinder
	tampa_inferior = $TampaInferior
	tampa_superior = $TampaSuperior
	
	_update_bed()
	_update_materials()
	_update_tampas()

func _update_bed():
	if main_cylinder and inner_cylinder:
		# Atualiza o cilindro principal
		main_cylinder.radius = diameter / 2.0
		main_cylinder.height = height
		
		# Ajusta a posição do cilindro principal para manter a base fixa
		main_cylinder.position.y = height / 2.0
		
		# Atualiza o cilindro interno
		inner_cylinder.radius = inner_cylinder_radius
		inner_cylinder.height = height * 1.38603  # Mantém a proporção
		inner_cylinder.position.y = -0.030771  # Mantém a posição relativa

func _update_materials():
	if main_cylinder:
		var material = main_cylinder.material_override as StandardMaterial3D
		if material:
			material.albedo_color.a = transparency
			material.emission = outline_color
			material.emission_energy_multiplier = 0.5
	
	if tampa_inferior and tampa_superior:
		var tampa_material = tampa_inferior.material as ShaderMaterial
		if tampa_material:
			tampa_material.set_shader_parameter("outline_color", outline_color)
			tampa_material.set_shader_parameter("transparency", transparency)
		
		tampa_material = tampa_superior.material as ShaderMaterial
		if tampa_material:
			tampa_material.set_shader_parameter("outline_color", outline_color)
			tampa_material.set_shader_parameter("transparency", transparency)

func _update_tampas():
	if tampa_inferior and tampa_superior:
		# Ajusta o raio das tampas para corresponder ao diâmetro do leito
		tampa_inferior.radius = (diameter / 2.0) + 0.035
		tampa_superior.radius = (diameter / 2.0) + 0.035
		
		# Ajusta a posição das tampas para acompanhar a altura do leito
		tampa_inferior.position.y = height + 1.15883  # Mantém a distância relativa
		tampa_superior.position.y = height - 1.35908  # Mantém a distância relativa
		
		# Atualiza a colisão das tampas baseado na visibilidade
		tampa_inferior.use_collision = tampa_inferior.visible
		tampa_superior.use_collision = tampa_superior.visible

func get_ponto_mais_baixo() -> float:
	# Calcula o ponto mais baixo do leito considerando a altura e a escala
	var ponto_mais_baixo = -height/2
	# Considera a posição global do leito
	ponto_mais_baixo += global_position.y
	
	# Garante que a tampa nunca fique abaixo do chão
	var ponto_minimo = FLOOR_Y + MIN_DISTANCE_FROM_FLOOR
	return max(ponto_mais_baixo, ponto_minimo)

func get_ponto_mais_alto() -> float:
	# Calcula o ponto mais alto do leito considerando a altura e a escala
	var ponto_mais_alto = height/2
	# Considera a posição global do leito
	ponto_mais_alto += global_position.y
	
	# Garante que a tampa nunca ultrapasse a altura máxima
	var ponto_maximo = MAX_HEIGHT - MIN_DISTANCE_FROM_BED
	return min(ponto_mais_alto, ponto_maximo)

func update_tampas():
	# Configurações comuns para ambas as tampas
	var tampa_radius = (diameter / 2.0) * 1.05  # Slightly larger than the bed
	var tampa_height = 0.01  # Very thin
	var tampa_scale = width  # Scale with bed width
	
	# Atualiza a tampa superior (que está no topo do leito)
	if tampa_superior:
		tampa_superior.radius = tampa_radius
		tampa_superior.height = tampa_height
		# Calcula a posição baseada no ponto mais alto do leito
		var ponto_mais_alto = get_ponto_mais_alto()
		tampa_superior.global_position.y = ponto_mais_alto + MIN_DISTANCE_FROM_BED
		tampa_superior.scale.x = tampa_scale
		update_tampa_material(tampa_superior)
	
	# Atualiza a tampa inferior (que está na base do leito)
	if tampa_inferior:
		tampa_inferior.radius = tampa_radius
		tampa_inferior.height = tampa_height
		# Calcula a posição baseada no ponto mais baixo do leito
		var ponto_mais_baixo = get_ponto_mais_baixo()
		tampa_inferior.global_position.y = ponto_mais_baixo - MIN_DISTANCE_FROM_BED
		tampa_inferior.scale.x = tampa_scale
		update_tampa_material(tampa_inferior)

func update_tampa_material(tampa: CSGCylinder3D):
	if tampa.material_override is StandardMaterial3D:
		var material = tampa.material_override as StandardMaterial3D
		material.unshaded = true
		material.albedo_color.a = transparency
		material.emission = outline_color

func reset_bed():
	height = INITIAL_HEIGHT
	width = INITIAL_WIDTH
	diameter = INITIAL_DIAMETER
	inner_cylinder_radius = INITIAL_INNER_RADIUS
	outline_color = INITIAL_OUTLINE_COLOR
	transparency = INITIAL_TRANSPARENCY
	
	_update_bed()
	_update_materials()
	_update_tampas()
	emit_signal("bed_reset")

func confirm_boolean():
	# Garante que a operação é subtração
	inner_cylinder.operation = CSGShape3D.OPERATION_SUBTRACTION
	_update_materials() 
