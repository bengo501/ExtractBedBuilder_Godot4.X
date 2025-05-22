extends Node3D

@export var height: float = 2.0
@export var width: float = 1.0
@export var diameter: float = 1.0
@export var inner_cylinder_radius: float = 0.4
@export var operation_type: int = 0  # 0 = Subtração, 1 = União, 2 = Interseção
@export var outline_color: Color = Color(0.0, 0.8, 1.0, 1.0)
@export var transparency: float = 0.3

@onready var cylinder: CSGCylinder3D = $CSGCylinder3D
@onready var inner_cylinder: CSGCylinder3D = $InnerCylinder

func _ready():
	update_cylinder()
	update_inner_cylinder()
	update_material()

func update_cylinder():
	cylinder.height = height
	cylinder.radius = diameter / 2.0
	# Scale the cylinder to match width
	cylinder.scale.x = width
	update_inner_cylinder()

func update_inner_cylinder():
	inner_cylinder.height = height * 0.98
	inner_cylinder.radius = inner_cylinder_radius
	inner_cylinder.visible = true
	# Atualiza a operação booleana
	inner_cylinder.operation = operation_type

func update_material():
	if cylinder.material_override is StandardMaterial3D:
		var material = cylinder.material_override as StandardMaterial3D
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

func set_operation_type(new_type: int):
	operation_type = new_type
	update_inner_cylinder()

func set_outline_color(new_color: Color):
	outline_color = new_color
	update_material()

func set_transparency(new_transparency: float):
	transparency = new_transparency
	update_material()

func confirm_boolean():
	# Aplica a operação booleana
	inner_cylinder.operation = operation_type
	# Esconde o cilindro interno após a operação
	inner_cylinder.visible = false
	# Atualiza o material para mostrar o resultado
	update_material() 
