extends Node3D

@export var height: float = 2.0
@export var width: float = 1.0
@export var diameter: float = 1.0
@export var inner_cylinder_radius: float = 0.4

@onready var cylinder: CSGCylinder3D = $CSGCylinder3D
@onready var inner_cylinder: CSGCylinder3D = $InnerCylinder

func _ready():
	update_cylinder()
	update_inner_cylinder()

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

func confirm_boolean():
	inner_cylinder.visible = false 
