extends StaticBody3D

func _ready():
	# Configurar camada de colisão do chão (camada 8)
	collision_layer = 8
	collision_mask = 1  # Colide apenas com objetos (camada 1)
	
	# Conecta o sinal de colisão corretamente
	if not is_connected("body_entered", Callable(self, "_on_body_entered")):
		self.connect("body_entered", Callable(self, "_on_body_entered"))
		print("Floor deadzone initialized - Layer: ", collision_layer, " Mask: ", collision_mask)
		print("Collision signal connected successfully")
	else:
		print("Collision signal was already connected")
	
	# Verifica se o nó tem um CollisionShape3D
	var collision_shape = get_node_or_null("CollisionShape3D")
	if collision_shape:
		print("CollisionShape3D found and configured")
	else:
		push_error("No CollisionShape3D found on Floor node!")

func _process(_delta):
	# Debug: Mostrar posição do chão
	if Engine.get_frames_drawn() % 60 == 0:  # A cada segundo aproximadamente
		print("Floor position: ", global_position)
		print("Floor collision layer: ", collision_layer)
		print("Floor collision mask: ", collision_mask)
		
		# Verifica se o sinal está conectado
		if is_connected("body_entered", Callable(self, "_on_body_entered")):
			print("Collision signal is connected")
		else:
			push_error("Collision signal is not connected!")

func _on_body_entered(body: Node3D):
	print("=== COLLISION DETECTED ===")
	print("Collision with: ", body.name)
	print("Body type: ", body.get_class())
	
	# Verifica se o corpo que entrou é um objeto físico
	if body is RigidBody3D:
		print("RigidBody detected!")
		print("Body collision layer: ", body.collision_layer)
		print("Body collision mask: ", body.collision_mask)
		
		# Remove o objeto após um pequeno delay para evitar problemas de física
		await get_tree().create_timer(0.1).timeout
		if is_instance_valid(body):  # Verifica se o objeto ainda existe
			print("Removing object: ", body.name)
			body.queue_free()
			print("Object removed successfully")
		else:
			print("Object was already removed")
	else:
		print("Not a RigidBody, ignoring collision") 
