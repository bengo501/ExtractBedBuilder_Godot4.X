extends Camera3D

@export var move_speed: float = 5.0
@export var mouse_sensitivity: float = 0.03
@export var arrow_sensitivity: float = 1.0

var velocity := Vector3.ZERO
var input_dir := Vector3.ZERO
var rotating := false

func _ready():
    Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _unhandled_input(event):
    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
        if event.pressed:
            rotating = true
            Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
        else:
            rotating = false
            Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
    elif event is InputEventMouseMotion and rotating:
        rotate_y(-event.relative.x * mouse_sensitivity)
        # Bloqueia rotação X (pitch)
        # var pitch = -event.relative.y * mouse_sensitivity
        # var new_rot = rotation_degrees.x + rad_to_deg(pitch)
        # if new_rot > -89 and new_rot < 89:
        #     rotate_x(pitch)

func _process(delta):
    input_dir = Vector3.ZERO
    # WASD para movimento
    if Input.is_action_pressed("move_forward"):
        input_dir.z -= 1
    if Input.is_action_pressed("move_backward"):
        input_dir.z += 1
    if Input.is_action_pressed("move_left"):
        input_dir.x -= 1
    if Input.is_action_pressed("move_right"):
        input_dir.x += 1
    if Input.is_action_pressed("move_down") or Input.is_action_pressed("q"):
        input_dir.y -= 1
    if Input.is_action_pressed("move_up") or Input.is_action_pressed("e"):
        input_dir.y += 1
    input_dir = input_dir.normalized()
    # Corrigir direção do forward para não ficar invertido
    var forward = transform.basis.z
    var right = transform.basis.x
    var up = transform.basis.y
    velocity = (forward * input_dir.z + right * input_dir.x + up * input_dir.y) * move_speed
    translate(velocity * delta)

    # Setas para rotação (apenas yaw)
    var yaw = 0.0
    if Input.is_action_pressed("ui_left"):
        yaw += arrow_sensitivity * delta * 60.0
    if Input.is_action_pressed("ui_right"):
        yaw -= arrow_sensitivity * delta * 60.0
    if yaw != 0.0:
        rotate_y(deg_to_rad(yaw))
    # Não rotaciona mais no eixo X (pitch) 