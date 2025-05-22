extends RigidBody3D

var initial_position: Vector3
var is_stable: bool = false
var stability_timer: float = 0.0
var stability_threshold: float = 0.1
var stability_time_required: float = 1.0

func _ready():
	initial_position = global_transform.origin
	contact_monitor = true
	max_contacts_reported = 4
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _process(delta):
	if !is_stable:
		# Verifica se a esfera está se movendo muito
		if linear_velocity.length() < stability_threshold and angular_velocity.length() < stability_threshold:
			stability_timer += delta
			if stability_timer >= stability_time_required:
				is_stable = true
				# Ajusta a posição final para evitar sobreposição
				_adjust_final_position()
		else:
			stability_timer = 0.0

func _on_body_entered(body):
	if body.is_in_group("spheres"):
		# Aplica uma pequena força para evitar sobreposição
		var direction = global_transform.origin - body.global_transform.origin
		if direction.length() > 0:
			direction = direction.normalized()
			apply_central_impulse(direction * 0.1)

func _on_body_exited(body):
	pass

func _adjust_final_position():
	# Ajusta a posição final para evitar sobreposição
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.new()
	query.from = global_transform.origin
	query.to = global_transform.origin + Vector3(0, -0.5, 0)
	query.collision_mask = 1
	
	var result = space_state.intersect_ray(query)
	if result:
		global_transform.origin = result.position + Vector3(0, 0.15, 0) 