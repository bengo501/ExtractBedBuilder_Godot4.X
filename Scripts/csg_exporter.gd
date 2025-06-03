extends Node

# Função para exportar um CSGShape3D para arquivo OBJ
func export_csg_to_obj(csg: CSGShape3D, file_path: String) -> bool:
	if not csg:
		print("Erro: CSGShape3D inválido")
		return false
		
	# Obtém a malha do CSG
	var mesh_pairs = csg.get_meshes()
	if mesh_pairs.size() != 2 or typeof(mesh_pairs[0]) != TYPE_TRANSFORM3D or typeof(mesh_pairs[1]) != TYPE_OBJECT:
		print("Erro: Formato de malha CSG inválido")
		return false
		
	var mesh = mesh_pairs[1]
	var transform = mesh_pairs[0]
	
	# Cria o arquivo OBJ
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if not file:
		print("Erro ao criar arquivo:", file_path)
		return false
		
	# Escreve o cabeçalho do arquivo
	file.store_line("# Exported from Godot CSG")
	file.store_line("o " + csg.name)
	
	var vertex_offset = 0
	
	# Processa cada superfície da malha
	for surface_idx in range(mesh.get_surface_count()):
		var arrays = mesh.surface_get_arrays(surface_idx)
		var vertices = arrays[ArrayMesh.ARRAY_VERTEX]
		var indices = arrays[ArrayMesh.ARRAY_INDEX]
		
		if vertices == null or vertices.size() == 0:
			continue
			
		# Escreve os vértices
		for vertex in vertices:
			var transformed_vertex = transform * vertex
			file.store_line("v %.6f %.6f %.6f" % [transformed_vertex.x, transformed_vertex.y, transformed_vertex.z])
			
		# Escreve as faces
		if indices != null and indices.size() > 0:
			for i in range(0, indices.size(), 3):
				var v1 = indices[i] + vertex_offset + 1
				var v2 = indices[i + 1] + vertex_offset + 1
				var v3 = indices[i + 2] + vertex_offset + 1
				file.store_line("f %d %d %d" % [v1, v2, v3])
				
		vertex_offset += vertices.size()
	
	file.close()
	print("CSG exportado com sucesso para:", file_path)
	return true

# Função para exportar todos os CSGs de um nó
func export_all_csgs_to_obj(root_node: Node, base_path: String) -> void:
	for child in root_node.get_children():
		if child is CSGShape3D:
			var file_path = base_path.path_join(child.name + ".obj")
			export_csg_to_obj(child, file_path)
		# Busca recursivamente em todos os filhos
		export_all_csgs_to_obj(child, base_path) 