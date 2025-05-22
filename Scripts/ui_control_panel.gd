extends Control

@onready var height_slider: HSlider = $VBoxContainer/HeightContainer/HeightSlider
@onready var width_slider: HSlider = $VBoxContainer/WidthContainer/WidthSlider
@onready var diameter_slider: HSlider = $VBoxContainer/DiameterContainer/DiameterSlider
@onready var height_value: Label = $VBoxContainer/HeightContainer/HeightValue
@onready var width_value: Label = $VBoxContainer/WidthContainer/WidthValue
@onready var diameter_value: Label = $VBoxContainer/DiameterContainer/DiameterValue
@onready var inner_radius_slider: HSlider = $VBoxContainer/InnerCylinderContainer/InnerRadiusSlider
@onready var inner_radius_value: Label = $VBoxContainer/InnerCylinderContainer/InnerRadiusValue
@onready var confirm_button: Button = $VBoxContainer/InnerCylinderContainer/ConfirmButton
@onready var outline_color_button: ColorPickerButton = $VBoxContainer/OutlineContainer/OutlineColorContainer/OutlineColorButton
@onready var transparency_slider: HSlider = $VBoxContainer/OutlineContainer/TransparencyContainer/TransparencySlider
@onready var transparency_value: Label = $VBoxContainer/OutlineContainer/TransparencyContainer/TransparencyValue

@export var extraction_bed_path: NodePath
var extraction_bed: Node3D
var camera_controller: Node

func _ready():
	extraction_bed = get_node(extraction_bed_path)
	camera_controller = get_node("../CameraController")
	
	# Initialize sliders with current values
	height_slider.value = extraction_bed.height
	width_slider.value = extraction_bed.width
	diameter_slider.value = extraction_bed.diameter
	inner_radius_slider.value = extraction_bed.inner_cylinder_radius
	outline_color_button.color = extraction_bed.outline_color
	transparency_slider.value = extraction_bed.transparency
	
	update_labels()
	confirm_button.pressed.connect(_on_confirm_button_pressed)
	
	# Conectar sinais dos sliders
	$VBoxContainer/HeightContainer/HeightSlider.value_changed.connect(_on_height_slider_value_changed)
	$VBoxContainer/WidthContainer/WidthSlider.value_changed.connect(_on_width_slider_value_changed)
	$VBoxContainer/DiameterContainer/DiameterSlider.value_changed.connect(_on_diameter_slider_value_changed)
	$VBoxContainer/InnerCylinderContainer/InnerRadiusSlider.value_changed.connect(_on_inner_radius_slider_value_changed)
	outline_color_button.color_changed.connect(_on_outline_color_changed)
	transparency_slider.value_changed.connect(_on_transparency_changed)
	
	# Conectar botões de zoom
	$VBoxContainer/ZoomContainer/ZoomInButton.pressed.connect(_on_zoom_in_pressed)
	$VBoxContainer/ZoomContainer/ZoomOutButton.pressed.connect(_on_zoom_out_pressed)

func _on_height_slider_value_changed(value: float):
	extraction_bed.set_height(value)
	height_value.text = str(value)
	
func _on_width_slider_value_changed(value: float):
	extraction_bed.set_width(value)
	width_value.text = str(value)
	
func _on_diameter_slider_value_changed(value: float):
	extraction_bed.set_diameter(value)
	diameter_value.text = str(value)

func _on_inner_radius_slider_value_changed(value: float):
	extraction_bed.set_inner_cylinder_radius(value)
	inner_radius_value.text = str(value)

func _on_confirm_button_pressed():
	extraction_bed.confirm_boolean()

func _on_zoom_in_pressed():
	camera_controller.zoom_in()

func _on_zoom_out_pressed():
	camera_controller.zoom_out()

func _on_outline_color_changed(color: Color):
	extraction_bed.set_outline_color(color)

func _on_transparency_changed(value: float):
	extraction_bed.set_transparency(value)
	transparency_value.text = str(value)

func update_labels():
	height_value.text = str(height_slider.value)
	width_value.text = str(width_slider.value)
	diameter_value.text = str(diameter_slider.value)
	inner_radius_value.text = str(inner_radius_slider.value) 
