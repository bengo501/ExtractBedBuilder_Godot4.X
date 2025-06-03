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
	
	# Configurar camadas de colisão
	collision_layer = 1  # Camada 1 para objetos
	collision_mask = 1 | 2 | 4 | 8  # Colide com objetos (1), tampas (2,4) e chão (8)
	
	print("Sphere initialized - Layer: ", collision_layer, " Mask: ", collision_mask)

func _process(delta):
	if !is_stable:
		# Verifica se a esfera está se movendo muito
		if linear_velocity.length() < stability_threshold and angular_velocity.length() < stability_threshold:
			stability_timer += delta
			if stability_timer >= stability_time_required:
				is_stable = true
				print("Sphere stabilized at position: ", global_transform.origin)
				# Ajusta a posição final para evitar sobreposição
				_adjust_final_position()
		else:
			stability_timer = 0.0

func _on_body_entered(body):
	print("Sphere collision with: ", body.name)
	print("Collision body type: ", body.get_class())
	print("Collision body layer: ", body.collision_layer if body.has_method("get_collision_layer") else "N/A")
	print("Collision body mask: ", body.collision_mask if body.has_method("get_collision_mask") else "N/A")

	# Deadzone logic: remove if collides with floor
	if (body is StaticBody3D and body.collision_layer == 8) or body.name == "Floor":
		print("Collided with floor! Removing object...")
		await get_tree().create_timer(0.1).timeout
		if is_instance_valid(self):
			queue_free()
			print("Object removed after floor collision!")
		return

	if body.is_in_group("spheres"):
		# Aplica uma pequena força para evitar sobreposição
		var direction = global_transform.origin - body.global_transform.origin
		if direction.length() > 0:
			direction = direction.normalized()
			apply_central_impulse(direction * 0.1)
			print("Applied impulse to avoid overlap")

func _on_body_exited(body):
	print("Sphere exited collision with: ", body.name)

func _adjust_final_position():
	# Ajusta a posição final para evitar sobreposição
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.new()
	query.from = global_transform.origin
	query.to = global_transform.origin + Vector3(0, -0.5, 0)
	query.collision_mask = 1 | 8  # Colide com objetos e chão
	
	var result = space_state.intersect_ray(query)
	if result:
		global_transform.origin = result.position + Vector3(0, 0.15, 0)
		print("Adjusted final position to: ", global_transform.origin) 