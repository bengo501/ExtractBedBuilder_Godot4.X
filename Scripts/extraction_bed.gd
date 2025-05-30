extends Node3D

signal bed_reset

# Valores iniciais do leito
const INITIAL_HEIGHT = 2.0
const INITIAL_WIDTH = 1.0
const INITIAL_DIAMETER = 1.0
const INITIAL_INNER_RADIUS = 0.4
const INITIAL_OUTLINE_COLOR = Color(0.0, 0.8, 1.0, 1.0)
const INITIAL_TRANSPARENCY = 0.3

@export var height: float = INITIAL_HEIGHT
@export var width: float = INITIAL_WIDTH
@export var diameter: float = INITIAL_DIAMETER
@export var inner_cylinder_radius: float = INITIAL_INNER_RADIUS
@export var outline_color: Color = INITIAL_OUTLINE_COLOR
@export var transparency: float = INITIAL_TRANSPARENCY

@onready var cylinder: CSGCylinder3D = $CSGCylinder3D
@onready var inner_cylinder: CSGCylinder3D = $CSGCylinder3D/InnerCylinder
@onready var tampa_superior: CSGCylinder3D = $TampaInferior  # Corrigido: TampaInferior é na verdade a superior
@onready var tampa_inferior: CSGCylinder3D = $TampaSuperior  # Corrigido: TampaSuperior é na verdade a inferior

# Constantes para o posicionamento
const FLOOR_Y = 0.0  # Posição Y do chão
const MIN_DISTANCE_FROM_FLOOR = 0.1  # Distância mínima do chão
const MIN_DISTANCE_FROM_BED = 0.001  # Distância mínima do leito
const MAX_HEIGHT = 10.0  # Altura máxima permitida

func _ready():
	update_cylinder()
	update_inner_cylinder()
	update_material()
	update_tampas()

func update_cylinder():
	cylinder.height = height
	cylinder.radius = diameter / 2.0
	# Scale the cylinder to match width
	cylinder.scale.x = width
	update_inner_cylinder()
	update_tampas()

func update_inner_cylinder():
	inner_cylinder.height = height * 0.98
	inner_cylinder.radius = inner_cylinder_radius
	inner_cylinder.visible = true
	# Garante que a operação é sempre subtração (furo)
	inner_cylinder.operation = CSGShape3D.OPERATION_SUBTRACTION

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

func update_material():
	if cylinder.material_override is StandardMaterial3D:
		var material = cylinder.material_override as StandardMaterial3D
		material.unshaded = true
		material.albedo_color.a = transparency
		material.emission = outline_color

func set_height(new_height: float):
	height = new_height
	update_cylinder()

func set_width(new_width: float):
	width = new_width
	update_cylinder()

func set_diameter(new_diameter: float):
	diameter = new_diameter
	update_cylinder()

func set_inner_cylinder_radius(new_radius: float):
	inner_cylinder_radius = new_radius
	update_inner_cylinder()

func set_outline_color(new_color: Color):
	outline_color = new_color
	update_material()
	update_tampas()  # Atualiza também o material das tampas

func set_transparency(new_transparency: float):
	transparency = new_transparency
	update_material()
	update_tampas()  # Atualiza também o material das tampas

func reset_bed():
	# Reseta todos os parâmetros para os valores iniciais
	height = INITIAL_HEIGHT
	width = INITIAL_WIDTH
	diameter = INITIAL_DIAMETER
	inner_cylinder_radius = INITIAL_INNER_RADIUS
	outline_color = INITIAL_OUTLINE_COLOR
	transparency = INITIAL_TRANSPARENCY
	
	# Atualiza o leito com os novos valores
	update_cylinder()
	update_inner_cylinder()
	update_material()
	update_tampas()
	
	# Emite um sinal para atualizar a UI
	emit_signal("bed_reset")

func confirm_boolean():
	# Garante que a operação é subtração
	inner_cylinder.operation = CSGShape3D.OPERATION_SUBTRACTION
	update_material() 
