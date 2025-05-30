extends Control

@onready var height_slider: HSlider = $VBoxContainer/HeightContainer/HeightSlider
@onready var width_slider: HSlider = $VBoxContainer/WidthContainer/WidthSlider
@onready var diameter_slider: HSlider = $VBoxContainer/DiameterContainer/DiameterSlider
@onready var height_value: Label = $VBoxContainer/HeightContainer/HeightValue
@onready var width_value: Label = $VBoxContainer/WidthContainer/WidthValue
@onready var diameter_value: Label = $VBoxContainer/DiameterContainer/DiameterValue
@onready var inner_radius_slider: HSlider = $VBoxContainer/InnerCylinderContainer/InnerRadiusSlider
@onready var inner_radius_value: Label = $VBoxContainer/InnerCylinderContainer/InnerRadiusValue
@onready var outline_color_button: ColorPickerButton = $VBoxContainer/OutlineContainer/OutlineColorContainer/OutlineColorButton
@onready var transparency_slider: HSlider = $VBoxContainer/OutlineContainer/TransparencyContainer/TransparencySlider
@onready var transparency_value: Label = $VBoxContainer/OutlineContainer/TransparencyContainer/TransparencyValue
@onready var tampa_inferior_button: Button = $VBoxContainer/TampasContainer/TampaInferiorButton
@onready var tampa_superior_button: Button = $VBoxContainer/TampasContainer/TampaSuperiorButton
@onready var zoom_value: Label = $VBoxContainer/ZoomContainer/ZoomValue
@onready var reset_button: Button = $VBoxContainer/ResetButton
@onready var skybox_button: Button = $VBoxContainer/SkyboxButton
@onready var skybox_intensity_slider: HSlider = $VBoxContainer/SkyboxContainer/SkyboxIntensitySlider
@onready var skybox_intensity_value: Label = $VBoxContainer/SkyboxContainer/SkyboxIntensityValue

@export var extraction_bed_path: NodePath
@export var skybox_manager_path: NodePath
var extraction_bed: Node3D
var camera_controller: Node
var skybox_manager: Node

var tampa_inferior: CSGCylinder3D
var tampa_superior: CSGCylinder3D

func _ready():
	extraction_bed = get_node(extraction_bed_path)
	camera_controller = get_node("../CameraController")
	skybox_manager = get_node(skybox_manager_path)
	
	# Initialize sliders with current values
	height_slider.value = extraction_bed.height
	width_slider.value = extraction_bed.width
	diameter_slider.value = extraction_bed.diameter
	inner_radius_slider.value = extraction_bed.inner_cylinder_radius
	outline_color_button.color = extraction_bed.outline_color
	transparency_slider.value = extraction_bed.transparency
	skybox_intensity_slider.value = skybox_manager.skybox_intensity
	
	update_labels()
	
	# Conectar sinais dos sliders
	$VBoxContainer/HeightContainer/HeightSlider.value_changed.connect(_on_height_slider_value_changed)
	$VBoxContainer/WidthContainer/WidthSlider.value_changed.connect(_on_width_slider_value_changed)
	$VBoxContainer/DiameterContainer/DiameterSlider.value_changed.connect(_on_diameter_slider_value_changed)
	$VBoxContainer/InnerCylinderContainer/InnerRadiusSlider.value_changed.connect(_on_inner_radius_slider_value_changed)
	outline_color_button.color_changed.connect(_on_outline_color_changed)
	transparency_slider.value_changed.connect(_on_transparency_changed)
	skybox_intensity_slider.value_changed.connect(_on_skybox_intensity_changed)
	
	# Conectar botões de zoom
	$VBoxContainer/ZoomContainer/ZoomInButton.pressed.connect(_on_zoom_in_pressed)
	$VBoxContainer/ZoomContainer/ZoomOutButton.pressed.connect(_on_zoom_out_pressed)
	
	# Conecta os sinais dos botões de tampa
	tampa_inferior_button.pressed.connect(_on_tampa_inferior_button_pressed)
	tampa_superior_button.pressed.connect(_on_tampa_superior_button_pressed)
	
	# Conecta o botão de skybox
	skybox_button.pressed.connect(_on_skybox_button_pressed)
	
	# Conecta os sinais de clique nos valores
	height_value.gui_input.connect(_on_height_value_gui_input)
	width_value.gui_input.connect(_on_width_value_gui_input)
	diameter_value.gui_input.connect(_on_diameter_value_gui_input)
	inner_radius_value.gui_input.connect(_on_inner_radius_value_gui_input)
	transparency_value.gui_input.connect(_on_transparency_value_gui_input)
	
	# Conecta o botão de reset
	reset_button.pressed.connect(_on_reset_button_pressed)
	
	# Inicializa as tampas como nodes já existentes
	tampa_inferior = extraction_bed.get_node_or_null("TampaInferior")
	tampa_superior = extraction_bed.get_node_or_null("TampaSuperior")
	# Garante que começam invisíveis
	if tampa_inferior:
		tampa_inferior.visible = false
	if tampa_superior:
		tampa_superior.visible = false
	
	# Atualiza o texto dos botões baseado no estado atual
	_update_tampa_buttons()

func _on_height_slider_value_changed(value: float):
	extraction_bed.height = value
	height_value.text = str(value)
	if extraction_bed:
		extraction_bed.scale.y = value
		# Atualiza a posição e raio das tampas se existirem
		if tampa_inferior:
			tampa_inferior.transform.origin.y = -value/2 + tampa_inferior.height * 0.5 - 0.0001
			tampa_inferior.radius = (diameter_slider.value / 2) * 1.05
		if tampa_superior:
			tampa_superior.transform.origin.y = value/2 - tampa_superior.height * 0.5 + 0.0001
			tampa_superior.radius = (diameter_slider.value / 2) * 1.05

func _on_width_slider_value_changed(value: float):
	extraction_bed.width = value
	width_value.text = str(value)
	if extraction_bed:
		extraction_bed.scale.x = value
		extraction_bed.scale.z = value

func _on_diameter_slider_value_changed(value: float):
	extraction_bed.diameter = value
	diameter_value.text = str(value)
	if extraction_bed:
		var cylinder = extraction_bed.get_node("CSGCylinder3D")
		if cylinder:
			cylinder.radius = value / 2
		# Atualiza o raio das tampas se existirem
		if tampa_inferior:
			tampa_inferior.radius = value / 2
		if tampa_superior:
			tampa_superior.radius = value / 2

func _on_inner_radius_slider_value_changed(value: float):
	extraction_bed.inner_cylinder_radius = value
	inner_radius_value.text = str(value)
	if extraction_bed:
		var inner_cylinder = extraction_bed.get_node("CSGCylinder3D/InnerCylinder")
		if inner_cylinder:
			inner_cylinder.radius = value

func _on_zoom_in_pressed():
	camera_controller.zoom_in()
	zoom_value.text = str(camera_controller.current_zoom)

func _on_zoom_out_pressed():
	camera_controller.zoom_out()
	zoom_value.text = str(camera_controller.current_zoom)

func _on_outline_color_changed(color: Color):
	extraction_bed.outline_color = color

func _on_transparency_changed(value: float):
	extraction_bed.transparency = value
	transparency_value.text = str(value)

func _on_tampa_inferior_button_pressed():
	if tampa_inferior:
		tampa_inferior.visible = not tampa_inferior.visible
	_update_tampa_buttons()

func _on_tampa_superior_button_pressed():
	if tampa_superior:
		tampa_superior.visible = not tampa_superior.visible
	_update_tampa_buttons()

func _update_tampa_buttons():
	if tampa_inferior and tampa_inferior.visible:
		tampa_inferior_button.text = "Remover Tampa Inferior"
	else:
		tampa_inferior_button.text = "Adicionar Tampa Inferior"
	if tampa_superior and tampa_superior.visible:
		tampa_superior_button.text = "Remover Tampa Superior"
	else:
		tampa_superior_button.text = "Adicionar Tampa Superior"

func update_labels():
	height_value.text = str(height_slider.value)
	width_value.text = str(width_slider.value)
	diameter_value.text = str(diameter_slider.value)
	inner_radius_value.text = str(inner_radius_slider.value)
	transparency_value.text = str(transparency_slider.value)
	zoom_value.text = str(camera_controller.current_zoom)
	skybox_intensity_value.text = str(skybox_intensity_slider.value)

func _on_height_value_gui_input(event: InputEvent):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var new_value = await _show_number_dialog("Altura", height_slider.value, height_slider.min_value, height_slider.max_value)
		if new_value != null:
			height_slider.value = new_value

func _on_width_value_gui_input(event: InputEvent):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var new_value = await _show_number_dialog("Largura", width_slider.value, width_slider.min_value, width_slider.max_value)
		if new_value != null:
			width_slider.value = new_value

func _on_diameter_value_gui_input(event: InputEvent):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var new_value = await _show_number_dialog("Diâmetro", diameter_slider.value, diameter_slider.min_value, diameter_slider.max_value)
		if new_value != null:
			diameter_slider.value = new_value

func _on_inner_radius_value_gui_input(event: InputEvent):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var new_value = await _show_number_dialog("Raio do Espaço Interno", inner_radius_slider.value, inner_radius_slider.min_value, inner_radius_slider.max_value)
		if new_value != null:
			inner_radius_slider.value = new_value

func _on_transparency_value_gui_input(event: InputEvent):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var new_value = await _show_number_dialog("Transparência", transparency_slider.value, transparency_slider.min_value, transparency_slider.max_value)
		if new_value != null:
			transparency_slider.value = new_value

func _show_number_dialog(title: String, current_value: float, min_value: float, max_value: float):
	var dialog = AcceptDialog.new()
	var line_edit = LineEdit.new()
	
	dialog.title = title
	dialog.dialog_text = "Digite o novo valor:"
	dialog.custom_minimum_size = Vector2(300, 100)
	
	line_edit.text = str(current_value)
	line_edit.custom_minimum_size = Vector2(280, 30)
	line_edit.position = Vector2(10, 40)
	
	dialog.add_child(line_edit)
	add_child(dialog)
	
	dialog.popup_centered()
	
	var result = await dialog.confirmed
	
	if result:
		var new_value = float(line_edit.text)
		if new_value >= min_value and new_value <= max_value:
			dialog.queue_free()
			return new_value
	
	dialog.queue_free()
	return null

func _on_reset_button_pressed():
	extraction_bed.reset_bed()
	# Atualiza os sliders e valores para refletir o reset
	height_slider.value = extraction_bed.height
	width_slider.value = extraction_bed.width
	diameter_slider.value = extraction_bed.diameter
	inner_radius_slider.value = extraction_bed.inner_cylinder_radius
	outline_color_button.color = extraction_bed.outline_color
	transparency_slider.value = extraction_bed.transparency
	skybox_intensity_slider.value = skybox_manager.skybox_intensity
	update_labels() 

func _on_skybox_button_pressed():
	skybox_manager.toggle_skybox()
	skybox_button.text = "Grid Preta" if skybox_manager.current_skybox == "white" else "Grid Branca" 

func _on_skybox_intensity_changed(value: float):
	skybox_manager.skybox_intensity = value
	skybox_intensity_value.text = str(value)
	skybox_manager.load_skybox(skybox_manager.skybox_white_path if skybox_manager.current_skybox == "white" else skybox_manager.skybox_black_path) 
