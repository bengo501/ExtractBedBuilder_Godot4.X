extends Node

signal export_progress(progress: float)
signal export_complete(success: bool, message: String)

var extraction_bed: Node3D
var spawner: Node

func _ready():
	extraction_bed = get_node("/root/MainScene/ExtractionBed")
	spawner = get_node("/root/MainScene/ExtractionBed/Spawner")

func export_model(format: String, file_path: String) -> void:
	if not extraction_bed or not spawner:
		emit_signal("export_complete", false, "Erro: Leito de extração ou spawner não encontrados")
		return
	
	# Criar um nó temporário para combinar todos os modelos
	var combined_model = Node3D.new()
	add_child(combined_model)
	
	# Adicionar o leito de extração
	var bed_mesh = extraction_bed.get_node("CSGCylinder3D")
	if bed_mesh:
		var bed_instance = bed_mesh.duplicate()
		combined_model.add_child(bed_instance)
	
	# Adicionar as tampas se estiverem visíveis
	var tampa_inferior = extraction_bed.get_node("CSGCylinder3D/TampaInferior")
	var tampa_superior = extraction_bed.get_node("CSGCylinder3D/TampaSuperior")
	
	if tampa_inferior and tampa_inferior.visible:
		var tampa_inferior_instance = tampa_inferior.duplicate()
		combined_model.add_child(tampa_inferior_instance)
	
	if tampa_superior and tampa_superior.visible:
		var tampa_superior_instance = tampa_superior.duplicate()
		combined_model.add_child(tampa_superior_instance)
	
	# Adicionar todos os objetos spawnados
	var total_objects = spawner.get_child_count() - 1  # -1 para excluir o SpawnerBlock
	var processed_objects = 0
	
	for child in spawner.get_children():
		if child is Node3D and child.name != "SpawnerBlock":
			var object_instance = child.duplicate()
			combined_model.add_child(object_instance)
			processed_objects += 1
			emit_signal("export_progress", float(processed_objects) / total_objects)
	
	# Exportar o modelo combinado
	match format.to_lower():
		"obj":
			_export_obj(combined_model, file_path)
		"fbx":
			_export_fbx(combined_model, file_path)
		"stl":
			_export_stl(combined_model, file_path)
		_:
			emit_signal("export_complete", false, "Formato não suportado: " + format)
	
	# Limpar o modelo temporário
	combined_model.queue_free()

func _export_obj(model: Node3D, file_path: String) -> void:
	var obj_data = ""
	var vertex_count = 0
	
	# Coletar todos os vértices e faces
	for child in model.get_children():
		if child is MeshInstance3D:
			var mesh = child.mesh
			if mesh:
				# Adicionar vértices
				for vertex in mesh.get_faces():
					vertex_count += 1
					obj_data += "v %.6f %.6f %.6f\n" % [vertex.x, vertex.y, vertex.z]
				
				# Adicionar faces
				var face_count = mesh.get_faces().size() / 3
				for i in range(face_count):
					var v1 = vertex_count - (face_count - i) * 3 + 1
					var v2 = v1 + 1
					var v3 = v1 + 2
					obj_data += "f %d %d %d\n" % [v1, v2, v3]
	
	# Salvar o arquivo
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if file:
		file.store_string(obj_data)
		file.close()
		emit_signal("export_complete", true, "Modelo exportado com sucesso para OBJ")
	else:
		emit_signal("export_complete", false, "Erro ao salvar arquivo OBJ")

func _export_fbx(model: Node3D, file_path: String) -> void:
	# Nota: A exportação FBX requer bibliotecas externas ou plugins
	# Por enquanto, vamos apenas mostrar uma mensagem
	emit_signal("export_complete", false, "Exportação FBX ainda não implementada")

func _export_stl(model: Node3D, file_path: String) -> void:
	var stl_data = "solid model\n"
	
	# Coletar todos os triângulos
	for child in model.get_children():
		if child is MeshInstance3D:
			var mesh = child.mesh
			if mesh:
				var faces = mesh.get_faces()
				for i in range(0, faces.size(), 3):
					var v1 = faces[i]
					var v2 = faces[i + 1]
					var v3 = faces[i + 2]
					
					# Calcular normal do triângulo
					var normal = (v2 - v1).cross(v3 - v1).normalized()
					
					# Adicionar face ao STL
					stl_data += "facet normal %.6f %.6f %.6f\n" % [normal.x, normal.y, normal.z]
					stl_data += "  outer loop\n"
					stl_data += "    vertex %.6f %.6f %.6f\n" % [v1.x, v1.y, v1.z]
					stl_data += "    vertex %.6f %.6f %.6f\n" % [v2.x, v2.y, v2.z]
					stl_data += "    vertex %.6f %.6f %.6f\n" % [v3.x, v3.y, v3.z]
					stl_data += "  endloop\n"
					stl_data += "endfacet\n"
	
	stl_data += "endsolid model\n"
	
	# Salvar o arquivo
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if file:
		file.store_string(stl_data)
		file.close()
		emit_signal("export_complete", true, "Modelo exportado com sucesso para STL")
	else:
		emit_signal("export_complete", false, "Erro ao salvar arquivo STL") 