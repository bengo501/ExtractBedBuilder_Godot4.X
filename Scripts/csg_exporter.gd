extends Node

# Função auxiliar para converter CSG em MeshInstance3D temporário
func _csg_to_mesh_instance(csg: CSGShape3D) -> MeshInstance3D:
	print("[CSGExporter] Convertendo CSG para MeshInstance3D temporário:", csg.name)
	var mesh_pairs = csg.get_meshes()
	if mesh_pairs.size() != 2 or typeof(mesh_pairs[1]) != TYPE_OBJECT:
		print("[CSGExporter] Erro ao obter mesh do CSG para conversão!")
		return null
	var orig_mesh : Mesh = mesh_pairs[1]
	var new_mesh : Mesh
	for i in orig_mesh.get_surface_count():
		var st = SurfaceTool.new()
		st.append_from(orig_mesh, i, Transform3D())
		st.set_material(orig_mesh.surface_get_material(i))
		st.index()
		if i == 0: new_mesh = st.commit()
		else: st.commit(new_mesh)
	var mesh_instance = MeshInstance3D.new()
	mesh_instance.mesh = new_mesh
	mesh_instance.global_transform = csg.global_transform
	return mesh_instance

# Função para exportar um CSGShape3D para arquivo OBJ
func export_csg_to_obj(csg: CSGShape3D, file_path: String) -> bool:
	print("[CSGExporter] Iniciando exportação do CSG:", csg.name)
	if not csg:
		print("[CSGExporter] Erro: CSGShape3D inválido")
		return false
	
	# Obtém a malha do CSG
	var mesh_pairs = csg.get_meshes()
	print("[CSGExporter] mesh_pairs:", mesh_pairs)
	if mesh_pairs.size() != 2 or typeof(mesh_pairs[0]) != TYPE_TRANSFORM3D or typeof(mesh_pairs[1]) != TYPE_OBJECT:
		print("[CSGExporter] Erro: Formato de malha CSG inválido")
		return false
	
	var mesh = mesh_pairs[1]
	var transform = mesh_pairs[0]
	print("[CSGExporter] mesh:", mesh, "transform:", transform)
	
	var has_faces := false
	var total_surfaces = mesh.get_surface_count()
	for surface_idx in range(total_surfaces):
		var arrays = mesh.surface_get_arrays(surface_idx)
		if arrays == null or arrays.size() <= ArrayMesh.ARRAY_INDEX:
			continue
		var indices = arrays[ArrayMesh.ARRAY_INDEX]
		if indices != null and indices.size() > 0:
			has_faces = true
			break

	if not has_faces:
		print("[CSGExporter] Nenhuma face encontrada no CSG! Tentando converter para MeshInstance3D...")
		var mesh_instance = _csg_to_mesh_instance(csg)
		if mesh_instance and mesh_instance.mesh:
			print("[CSGExporter] MeshInstance3D criado com sucesso. Exportando mesh...")
			return export_mesh_to_obj(mesh_instance.mesh, mesh_instance.global_transform, csg.name, file_path)
		else:
			print("[CSGExporter] Falha ao converter CSG para MeshInstance3D!")
			return false
	else:
		return export_mesh_to_obj(mesh, transform, csg.name, file_path)

# Função para exportar uma Mesh (MeshInstance3D ou ArrayMesh) para OBJ
func export_mesh_to_obj(mesh: Mesh, transform: Transform3D, obj_name: String, file_path: String) -> bool:
	print("[CSGExporter] Exportando mesh para OBJ:", obj_name)
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if not file:
		print("[CSGExporter] Erro ao criar arquivo:", file_path)
		return false
	file.store_line("# Exported from Godot CSG")
	file.store_line("o " + obj_name)
	file.store_line("g " + obj_name)
	var vertex_offset = 0
	var total_vertices = 0
	var total_faces = 0
	var total_surfaces = mesh.get_surface_count()
	print("[CSGExporter] Superfícies encontradas:", total_surfaces)
	for surface_idx in range(total_surfaces):
		print("[CSGExporter] --- Superfície", surface_idx, "---")
		var arrays = mesh.surface_get_arrays(surface_idx)
		if arrays == null or arrays.size() <= ArrayMesh.ARRAY_INDEX:
			print("[CSGExporter] Superfície", surface_idx, ": arrays nulo ou tamanho insuficiente.")
			continue
		var vertices = arrays[ArrayMesh.ARRAY_VERTEX]
		var indices = arrays[ArrayMesh.ARRAY_INDEX]
		print("[CSGExporter] Superfície", surface_idx, ": vértices =", vertices.size() if vertices else 0, ", índices =", indices.size() if indices else 0)
		if vertices == null or vertices.size() == 0:
			print("[CSGExporter] Superfície", surface_idx, ": sem vértices, ignorando.")
			continue
		for vertex in vertices:
			var transformed_vertex = transform * vertex
			file.store_line("v %.6f %.6f %.6f" % [transformed_vertex.x, transformed_vertex.y, transformed_vertex.z])
		total_vertices += vertices.size()
		if indices != null and indices.size() > 0:
			for i in range(0, indices.size(), 3):
				if i + 2 >= indices.size():
					print("[CSGExporter] Superfície", surface_idx, ": índice incompleto em", i, ", ignorando triângulo.")
					continue
				var v1 = indices[i] + vertex_offset + 1
				var v2 = indices[i + 1] + vertex_offset + 1
				var v3 = indices[i + 2] + vertex_offset + 1
				file.store_line("f %d %d %d" % [v1, v2, v3])
				total_faces += 1
			print("[CSGExporter] Superfície", surface_idx, ": faces exportadas =", total_faces)
		else:
			print("[CSGExporter] Superfície", surface_idx, ": sem índices/faces.")
		vertex_offset += vertices.size()
	file.close()
	print("[CSGExporter] Exportação concluída para:", file_path)
	print("[CSGExporter] Total de vértices exportados:", total_vertices)
	print("[CSGExporter] Total de faces exportadas:", total_faces)
	if total_vertices == 0 or total_faces == 0:
		print("[CSGExporter] Aviso: OBJ exportado está vazio ou incompleto!")
		return false
	return true

# Função para exportar todos os CSGs de um nó
func export_all_csgs_to_obj(root_node: Node, base_path: String) -> void:
	print("[CSGExporter] Exportando todos os CSGs do nó:", root_node.name)
	for child in root_node.get_children():
		if child is CSGShape3D:
			var file_path = base_path.path_join(child.name + ".obj")
			print("[CSGExporter] Exportando CSG:", child.name, "para:", file_path)
			export_csg_to_obj(child, file_path)
		# Busca recursivamente em todos os filhos
		export_all_csgs_to_obj(child, base_path) 