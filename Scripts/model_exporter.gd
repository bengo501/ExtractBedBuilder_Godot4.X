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
	
	# Lista para armazenar todos os objetos
	var all_objects = []
	
	# Adicionar o leito de extração
	var bed_mesh = extraction_bed.get_node("CSGCylinder3D")
	if bed_mesh:
		all_objects.append(bed_mesh)
		
		# Adicionar o cilindro interno (para a operação de subtração)
		var inner_cylinder = extraction_bed.get_node("CSGCylinder3D/InnerCylinder")
		if inner_cylinder:
			all_objects.append(inner_cylinder)
	
	# Adicionar as tampas se estiverem visíveis
	var tampa_inferior = extraction_bed.get_node("CSGCylinder3D/TampaInferior")
	var tampa_superior = extraction_bed.get_node("CSGCylinder3D/TampaSuperior")
	
	if tampa_inferior and tampa_inferior.visible:
		all_objects.append(tampa_inferior)
	
	if tampa_superior and tampa_superior.visible:
		all_objects.append(tampa_superior)
	
	# Adicionar todos os objetos spawnados
	var total_objects = spawner.get_child_count() - 1  # -1 para excluir o SpawnerBlock
	var processed_objects = 0
	
	for child in spawner.get_children():
		if child is Node3D and child.name != "SpawnerBlock":
			all_objects.append(child)
			processed_objects += 1
			emit_signal("export_progress", float(processed_objects) / total_objects)
	
	# Exportar o modelo combinado
	match format.to_lower():
		"obj":
			_export_obj(all_objects, file_path)
		"fbx":
			_export_fbx(all_objects, file_path)
		"stl":
			_export_stl(all_objects, file_path)
		_:
			emit_signal("export_complete", false, "Formato não suportado: " + format)

func _get_mesh_data(object: Node3D) -> Dictionary:
	var mesh_data = {
		"vertices": [],
		"indices": [],
		"transform": object.global_transform
	}
	
	if object is MeshInstance3D:
		var mesh = object.mesh
		if mesh:
			# Obter dados da superfície
			var surface_count = mesh.get_surface_count()
			if surface_count > 0:
				var arrays = mesh.surface_get_arrays(0)
				if arrays.size() > 0:
					mesh_data.vertices = arrays[Mesh.ARRAY_VERTEX]
					mesh_data.indices = arrays[Mesh.ARRAY_INDEX]
	
	return mesh_data

func _export_obj(objects: Array, file_path: String) -> void:
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if not file:
		emit_signal("export_complete", false, "Erro ao abrir arquivo para escrita: " + file_path)
		return
	
	# Escrever cabeçalho do arquivo
	file.store_line("# Exportado pelo LeitoExtra")
	file.store_line("# Data: " + Time.get_datetime_string_from_system())
	
	var vertex_offset = 0
	
	# Coletar dados de todos os objetos
	for object in objects:
		var mesh_data = _get_mesh_data(object)
		if mesh_data.vertices.size() > 0:
			# Adicionar comentário com nome do objeto
			file.store_line("\n# Objeto: " + object.name)
			
			# Adicionar vértices transformados
			for vertex in mesh_data.vertices:
				var transformed_vertex = mesh_data.transform * vertex
				file.store_line("v %.6f %.6f %.6f" % [transformed_vertex.x, transformed_vertex.y, transformed_vertex.z])
			
			# Adicionar faces
			if mesh_data.indices.size() > 0:
				for i in range(0, mesh_data.indices.size(), 3):
					var v1 = mesh_data.indices[i] + vertex_offset + 1
					var v2 = mesh_data.indices[i + 1] + vertex_offset + 1
					var v3 = mesh_data.indices[i + 2] + vertex_offset + 1
					file.store_line("f %d %d %d" % [v1, v2, v3])
			
			vertex_offset += mesh_data.vertices.size()
	
	file.close()
	emit_signal("export_complete", true, "Modelo exportado com sucesso para OBJ")

func _export_fbx(objects: Array, file_path: String) -> void:
	emit_signal("export_complete", false, "Exportação FBX ainda não implementada")

func _export_stl(objects: Array, file_path: String) -> void:
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if not file:
		emit_signal("export_complete", false, "Erro ao abrir arquivo para escrita: " + file_path)
		return
	
	# Escrever cabeçalho do arquivo
	file.store_line("solid LeitoExtra")
	
	# Coletar dados de todos os objetos
	for object in objects:
		var mesh_data = _get_mesh_data(object)
		if mesh_data.vertices.size() > 0 and mesh_data.indices.size() > 0:
			# Adicionar comentário com nome do objeto
			file.store_line("\n# Objeto: " + object.name)
			
			for i in range(0, mesh_data.indices.size(), 3):
				var v1 = mesh_data.transform * mesh_data.vertices[mesh_data.indices[i]]
				var v2 = mesh_data.transform * mesh_data.vertices[mesh_data.indices[i + 1]]
				var v3 = mesh_data.transform * mesh_data.vertices[mesh_data.indices[i + 2]]
				
				# Calcular normal do triângulo
				var normal = (v2 - v1).cross(v3 - v1).normalized()
				
				# Adicionar face ao STL
				file.store_line("facet normal %.6f %.6f %.6f" % [normal.x, normal.y, normal.z])
				file.store_line("  outer loop")
				file.store_line("    vertex %.6f %.6f %.6f" % [v1.x, v1.y, v1.z])
				file.store_line("    vertex %.6f %.6f %.6f" % [v2.x, v2.y, v2.z])
				file.store_line("    vertex %.6f %.6f %.6f" % [v3.x, v3.y, v3.z])
				file.store_line("  endloop")
				file.store_line("endfacet")
	
	file.store_line("endsolid LeitoExtra")
	file.close()
	emit_signal("export_complete", true, "Modelo exportado com sucesso para STL") 
