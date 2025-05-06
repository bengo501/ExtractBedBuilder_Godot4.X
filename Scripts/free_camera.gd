extends Camera3D

@export var move_speed: float = 5.0
@export var mouse_sensitivity: float = 0.2

var velocity := Vector3.ZERO
var input_dir := Vector3.ZERO
var rotating := false
var last_mouse_pos := Vector2.ZERO

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
        rotate_y(-event.relative.x * mouse_sensitivity * 0.01)
        var pitch = -event.relative.y * mouse_sensitivity * 0.01
        var new_rot = rotation_degrees.x + rad_to_deg(pitch)
        if new_rot > -89 and new_rot < 89:
            rotate_x(pitch)

func _process(delta):
    input_dir = Vector3.ZERO
    if Input.is_action_pressed("ui_up") or Input.is_action_pressed("move_forward"):
        input_dir.z -= 1
    if Input.is_action_pressed("ui_down") or Input.is_action_pressed("move_backward"):
        input_dir.z += 1
    if Input.is_action_pressed("ui_left") or Input.is_action_pressed("move_left"):
        input_dir.x -= 1
    if Input.is_action_pressed("ui_right") or Input.is_action_pressed("move_right"):
        input_dir.x += 1
    input_dir = input_dir.normalized()
    var forward = -transform.basis.z
    var right = transform.basis.x
    velocity = (forward * input_dir.z + right * input_dir.x) * move_speed
    translate(velocity * delta) 