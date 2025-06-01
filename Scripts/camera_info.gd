extends Window

@onready var camera_indicator = $CameraIndicator
@onready var reset_button = $ResetButton

var camera_controller: Node

func _ready():
	# Configurar a janela
	close_requested.connect(_on_close_requested)
	
	# Garantir que a janela começa invisível
	visible = false
	
	# Obter referência ao controlador de câmera
	camera_controller = get_node("../CameraController")
	if not camera_controller:
		push_error("CameraInfo: CameraController não encontrado!")
		return
	
	# Conectar o botão de reset
	reset_button.pressed.connect(_on_reset_button_pressed)

func _on_close_requested():
	hide()

func update_info(camera_name: String, position: Vector3):
	var text = "Câmera: " + camera_name + "\n"
	text += "Posição: (%.2f, %.2f, %.2f)" % [position.x, position.y, position.z]
	camera_indicator.text = text

func _on_reset_button_pressed():
	if camera_controller:
		camera_controller.reset_cameras() 