extends Camera3D

@export var move_speed: float = 0.5

func _process(delta):
    var move = Vector3.ZERO
    if Input.is_action_pressed("ui_up"):
        move.z -= 1
    if Input.is_action_pressed("ui_down"):
        move.z += 1
    if Input.is_action_pressed("ui_left"):
        move.x -= 1
    if Input.is_action_pressed("ui_right"):
        move.x += 1
    if Input.is_action_pressed("move_up") or Input.is_action_pressed("e"):
        move.y += 1
    if Input.is_action_pressed("move_down") or Input.is_action_pressed("q"):
        move.y -= 1
    if move != Vector3.ZERO:
        global_translate(move.normalized() * move_speed) 