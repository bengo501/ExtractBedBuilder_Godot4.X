extends Node

signal export_progress(progress: float)
signal export_complete(success: bool, message: String)

var extraction_bed: Node3D
var spawner: Node

func _ready():
	extraction_bed = get_node("/root/MainScene/ExtractionBed")
	spawner = get_node("/root/MainScene/ExtractionBed/Spawner")

# Função auxiliar para adicionar mesh de um objeto
func _add_mesh_from_object(obj, all_meshes):
	if obj is MeshInstance3D:
		print("[Export] MeshInstance3D adicionado:", obj)
		all_meshes.append(obj)
	else:
		print("[Export] Objeto ignorado (não é MeshInstance3D):", obj)

# Função auxiliar para converter CSG em MeshInstance3D temporário
func _csg_to_mesh_instance(csg: CSGShape3D) -> MeshInstance3D:
	var orig_mesh : Mesh = csg.get_meshes()[1]
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

func export_model(format: String, file_path: String) -> void:
	var all_meshes = []
	var extraction_bed = get_node("/root/MainScene/ExtractionBed")
	if extraction_bed:
		for child in extraction_bed.get_children():
			if child is MeshInstance3D:
				all_meshes.append(child)
	var spawner = get_node("/root/MainScene/ExtractionBed/Spawner")
	if spawner:
		for child in spawner.get_children():
			if child is MeshInstance3D:
				all_meshes.append(child)
	_export_obj(all_meshes, file_path)

func _get_mesh_data(object) -> Dictionary:
	var mesh_data = {
		"vertices": [],
		"indices": [],
		"transform": Transform3D.IDENTITY
	}

	var mesh = null
	if object is MeshInstance3D:
		mesh = object.mesh
		mesh_data.transform = object.global_transform
	elif object is ArrayMesh:
		mesh = object
		# transform identidade
	else:
		print("[Export] Objeto ignorado em _get_mesh_data:", object)
		return mesh_data

	if mesh:
		var surface_count = mesh.get_surface_count()
		print("[Export] Mesh possui", surface_count, "superfícies para objeto:", object)
		if surface_count > 0:
			var arrays = mesh.surface_get_arrays(0)
			if arrays and arrays.size() > 0:
				mesh_data.vertices = arrays[Mesh.ARRAY_VERTEX]
				mesh_data.indices = arrays[Mesh.ARRAY_INDEX]
				print("[Export] Vértices exportados:", mesh_data.vertices.size(), "Índices exportados:", mesh_data.indices.size())
			else:
				print("[Export] Superfície 0 não encontrada ou vazia para mesh:", mesh)
	else:
		print("[Export] Nenhum mesh encontrado no objeto:", object)
	return mesh_data

func _export_obj(objects: Array, file_path: String) -> void:
	print("[Export] Iniciando exportação OBJ para:", file_path)
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if not file:
		print("[Export] Erro ao abrir arquivo para escrita:", file_path)
		emit_signal("export_complete", false, "Erro ao abrir arquivo para escrita: " + file_path)
		return
	
	# Escrever cabeçalho do arquivo
	file.store_line("# Exportado pelo LeitoExtra")
	file.store_line("# Data: " + Time.get_datetime_string_from_system())
	
	var vertex_offset = 0
	
	# Coletar dados de todos os objetos
	for object in objects:
		print("[Export] Lendo objeto para exportação:", object)
		var mesh_data = null
		if object is MeshInstance3D or object is ArrayMesh:
			mesh_data = _get_mesh_data(object)
			var vert_count = mesh_data.vertices.size() if mesh_data.vertices != null else 0
			var ind_count = mesh_data.indices.size() if mesh_data.indices != null else 0
			print("[Export] Objeto:", object, "Vértices:", vert_count, "Índices:", ind_count)
		else:
			print("[Export] Objeto ignorado (não é MeshInstance3D nem ArrayMesh):", object)
			continue
		if mesh_data.vertices != null and mesh_data.vertices.size() > 0:
			file.store_line("\n# Objeto: " + str(object))
			print("[Export] Escrevendo vértices do objeto:", object)
			for vertex in mesh_data.vertices:
				var transformed_vertex = mesh_data.transform * vertex
				file.store_line("v %.6f %.6f %.6f" % [transformed_vertex.x, transformed_vertex.y, transformed_vertex.z])
			print("[Export] Fim da escrita de vértices para objeto:", object)
			if mesh_data.indices != null and mesh_data.indices.size() > 0:
				print("[Export] Escrevendo faces do objeto:", object)
				for i in range(0, mesh_data.indices.size(), 3):
					var v1 = mesh_data.indices[i] + vertex_offset + 1
					var v2 = mesh_data.indices[i + 1] + vertex_offset + 1
					var v3 = mesh_data.indices[i + 2] + vertex_offset + 1
					file.store_line("f %d %d %d" % [v1, v2, v3])
				print("[Export] Fim da escrita de faces para objeto:", object)
			vertex_offset += mesh_data.vertices.size() if mesh_data.vertices != null else 0
		else:
			print("[Export] Mesh sem vértices, não será exportado:", object)
	
	file.close()
	print("[Export] Exportação OBJ finalizada para:", file_path)
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

func export_mesh_to_file(object: Node3D, save_path: String, file_name: String) -> void:
	print("[Export] Iniciando exportação para:", save_path, "Arquivo:", file_name)
	# Certifique-se de que o diretório existe
	var dir = DirAccess.open(save_path)
	if not dir:
		var err = DirAccess.make_dir_absolute(save_path)
		print("[Export] Diretório não existia, tentando criar. Resultado:", err)
		if err != OK:
			print("[Export] Erro ao criar diretório:", err)
			emit_signal("export_complete", false, "Erro ao criar diretório: " + str(err))
			return
	
	# Buscar MeshInstance3D ou CSGShape3D em qualquer nível da hierarquia
	var mesh_instance = null
	var csg_instance = null
	for child in object.get_children():
		if child is MeshInstance3D:
			mesh_instance = child
			print("[Export] MeshInstance3D encontrado como filho direto.")
			break
		elif child is CSGShape3D:
			csg_instance = child
			print("[Export] CSGShape3D encontrado como filho direto.")
			break
	if mesh_instance == null and csg_instance == null:
		# Busca recursiva
		var descendants = object.get_children()
		while descendants.size() > 0 and mesh_instance == null and csg_instance == null:
			var node = descendants.pop_front()
			if node is MeshInstance3D:
				mesh_instance = node
				print("[Export] MeshInstance3D encontrado na busca recursiva.")
				break
			elif node is CSGShape3D:
				csg_instance = node
				print("[Export] CSGShape3D encontrado na busca recursiva.")
				break
			descendants += node.get_children()
	if mesh_instance == null and csg_instance == null:
		print("[Export] Nenhum MeshInstance3D nem CSGShape3D encontrado!")
		emit_signal("export_complete", false, "Objeto não possui MeshInstance3D nem CSGShape3D")
		return
	
	# Conecte os sinais do OBJExporter
	if not OBJExporter.export_started.is_connected(_on_export_started):
		OBJExporter.export_started.connect(_on_export_started)
	if not OBJExporter.export_progress_updated.is_connected(_on_export_progress):
		OBJExporter.export_progress_updated.connect(_on_export_progress)
	if not OBJExporter.export_completed.is_connected(_on_export_completed):
		OBJExporter.export_completed.connect(_on_export_completed)
	
	# Se for MeshInstance3D, exporta normalmente
	if mesh_instance:
		print("[Export] Exportando MeshInstance3D...")
		_export_obj([mesh_instance], save_path.path_join(file_name + ".obj"))
		return
	
	# Se for CSGShape3D, converte para mesh e exporta
	if csg_instance:
		print("[Export] Exportando CSGShape3D...")
		var mesh_pairs = csg_instance.get_meshes()
		print("[Export] mesh_pairs:", mesh_pairs)
		if mesh_pairs.size() == 2 and typeof(mesh_pairs[0]) == TYPE_TRANSFORM3D and typeof(mesh_pairs[1]) == TYPE_OBJECT:
			var mesh = mesh_pairs[1]
			var csg_file_name = file_name + "_csg"
			print("[Export] Chamando _export_obj para mesh do CSG...")
			_export_obj([mesh], save_path.path_join(csg_file_name + ".obj"))
			return
		else:
			print("[Export] mesh_pairs retornou formato inesperado:", mesh_pairs)
			return

func _on_export_started() -> void:
	print("[Export] Exportação iniciada")

func _on_export_progress(surf_idx: int, progress: float) -> void:
	print("[Export] Progresso da superfície %d: %.2f%%" % [surf_idx, progress * 100])

func _on_export_completed(obj_file: String, mtl_file: String) -> void:
	print("[Export] Exportação concluída!")
	print("[Export] Arquivo OBJ: ", obj_file)
	print("[Export] Arquivo MTL: ", mtl_file)
	emit_signal("export_complete", true, "Modelo exportado com sucesso!") 
