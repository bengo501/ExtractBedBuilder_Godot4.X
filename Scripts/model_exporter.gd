extends Node

signal export_progress(progress: float)
signal export_complete(success: bool, message: String)

var extraction_bed: Node3D
var spawner: Node
var csg_exporter: Node
var export_dir: String = "res://exports"

func _ready():
	print("[ModelExporter] Inicializando exportador...")
	extraction_bed = get_node("/root/MainScene/ExtractionBed")
	spawner = get_node("/root/MainScene/ExtractionBed/Spawner")
	
	# Inicializar o exportador de CSG
	csg_exporter = Node.new()
	csg_exporter.set_script(load("res://Scripts/csg_exporter.gd"))
	add_child(csg_exporter)
	
	# Criar diretório de exportação se não existir
	var dir = DirAccess.open("res://")
	if not dir.dir_exists("exports"):
		print("[ModelExporter] Criando diretório de exportação...")
		dir.make_dir("exports")

func export_model(format: String, file_path: String) -> void:
	print("[ModelExporter] Iniciando exportação no formato:", format)
	print("[ModelExporter] Caminho do arquivo:", file_path)
	
	if format.to_lower() == "obj":
		# Exportar todos os CSGs do leito e spawner
		var base_path = file_path.get_base_dir()
		var file_name = file_path.get_file().get_basename()
		
		print("[ModelExporter] Exportando CSGs do leito...")
		if extraction_bed:
			csg_exporter.export_all_csgs_to_obj(extraction_bed, base_path)
		
		print("[ModelExporter] Exportando CSGs do spawner...")
		if spawner:
			csg_exporter.export_all_csgs_to_obj(spawner, base_path)
		
		emit_signal("export_complete", true, "Modelo exportado com sucesso para OBJ")
	else:
		print("[ModelExporter] Formato não suportado:", format)
		emit_signal("export_complete", false, "Formato não suportado: " + format)

func export_mesh_to_file(object: Node3D, save_path: String, file_name: String) -> void:
	print("[ModelExporter] Exportando objeto:", object.name)
	print("[ModelExporter] Caminho de salvamento:", save_path)
	print("[ModelExporter] Nome do arquivo:", file_name)

	if object is CSGShape3D:
		var file_path = save_path.path_join(file_name + ".obj")
		print("[ModelExporter] Caminho completo do arquivo:", file_path)
		var success = csg_exporter.export_csg_to_obj(object, file_path)
		emit_signal("export_complete", success, "Modelo exportado com sucesso para OBJ" if success else "Erro ao exportar modelo")
		return

	# Se for um Node3D (ex: RigidBody3D), procurar CSGShape3D filhos
	if object is Node3D:
		var csgs = []
		for child in object.get_children():
			if child is CSGShape3D:
				csgs.append(child)
		if csgs.size() == 0:
			print("[ModelExporter] Nenhum CSGShape3D encontrado em:", object)
			emit_signal("export_complete", false, "Nenhum CSGShape3D encontrado no objeto selecionado")
			return
		print("[ModelExporter] Exportando", csgs.size(), "CSG(s) filho(s) de:", object.name)
		var all_success = true
		for csg in csgs:
			var csg_file_path = save_path.path_join(file_name + "_" + csg.name + ".obj")
			print("[ModelExporter] Exportando CSG:", csg.name, "para", csg_file_path)
			var success = csg_exporter.export_csg_to_obj(csg, csg_file_path)
			all_success = all_success and success
		emit_signal("export_complete", all_success, "Exportação finalizada. Verifique a pasta de exportação.")
		return

	print("[ModelExporter] Objeto não é um CSGShape3D nem possui filhos CSGShape3D:", object)
	emit_signal("export_complete", false, "Objeto não é um CSGShape3D nem possui filhos CSGShape3D")

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

func _on_export_started() -> void:
	print("[Export] Exportação iniciada")

func _on_export_progress(surf_idx: int, progress: float) -> void:
	print("[Export] Progresso da superfície %d: %.2f%%" % [surf_idx, progress * 100])

func _on_export_completed(obj_file: String, mtl_file: String) -> void:
	print("[Export] Exportação concluída!")
	print("[Export] Arquivo OBJ: ", obj_file)
	print("[Export] Arquivo MTL: ", mtl_file)
	emit_signal("export_complete", true, "Modelo exportado com sucesso!")

# Exporta todos os CSGs do leito e suas tampas
func export_bed_and_covers_to_obj(export_dir: String) -> void:
	print("[ModelExporter] Iniciando exportação do leito e tampas para OBJ...")
	if not extraction_bed:
		print("[ModelExporter] Erro: ExtractionBed não encontrado!")
		emit_signal("export_complete", false, "ExtractionBed não encontrado!")
		return
	print("[ModelExporter] Exportando CSGs do leito:", extraction_bed.name)
	csg_exporter.export_all_csgs_to_obj(extraction_bed, export_dir)
	for child in extraction_bed.get_children():
		if child.name.to_lower().find("tampa") != -1 or child.name.to_lower().find("cover") != -1:
			print("[ModelExporter] Exportando CSGs da tampa:", child.name)
			csg_exporter.export_all_csgs_to_obj(child, export_dir)
	print("[ModelExporter] Exportação do leito e tampas finalizada!")
	# Não emite sinal de conclusão aqui, pois pode ser chamado em lote 

# Exporta todos os CSGs dos objetos spawnados
func export_spawned_objects_to_obj(export_dir: String) -> void:
	print("[ModelExporter] Iniciando exportação dos objetos spawnados para OBJ...")
	if not spawner:
		print("[ModelExporter] Erro: Spawner não encontrado!")
		emit_signal("export_complete", false, "Spawner não encontrado!")
		return
	for child in spawner.get_children():
		if child is CSGShape3D:
			print("[ModelExporter] Exportando CSG do objeto spawnado:", child.name)
			csg_exporter.export_csg_to_obj(child, export_dir.path_join(child.name + ".obj"))
		# Se o objeto spawnado for um corpo físico, exportar todos os CSGs filhos
		elif child is Node3D:
			for subchild in child.get_children():
				if subchild is CSGShape3D:
					print("[ModelExporter] Exportando CSG filho de objeto spawnado:", subchild.name)
					csg_exporter.export_csg_to_obj(subchild, export_dir.path_join(subchild.name + ".obj"))
	print("[ModelExporter] Exportação dos objetos spawnados finalizada!")

# Exporta todos os CSGs do leito, tampas e objetos spawnados em um único arquivo OBJ
func export_all_to_single_obj(file_path: String) -> void:
	print("[ModelExporter] Iniciando exportação de todos os CSGs para um único OBJ...")
	var all_csgs: Array = []
	# Coletar CSGs do leito
	if extraction_bed:
		print("[ModelExporter] Coletando CSGs do leito:", extraction_bed.name)
		all_csgs += _collect_csgs_recursive(extraction_bed)
		# Coletar CSGs das tampas (filhos do leito com 'tampa' ou 'cover' no nome)
		for child in extraction_bed.get_children():
			if child.name.to_lower().find("tampa") != -1 or child.name.to_lower().find("cover") != -1:
				print("[ModelExporter] Coletando CSGs da tampa:", child.name)
				all_csgs += _collect_csgs_recursive(child)
	else:
		print("[ModelExporter] Aviso: ExtractionBed não encontrado!")
	# Coletar CSGs dos objetos spawnados
	if spawner:
		print("[ModelExporter] Coletando CSGs dos objetos spawnados...")
		for child in spawner.get_children():
			all_csgs += _collect_csgs_recursive(child)
	else:
		print("[ModelExporter] Aviso: Spawner não encontrado!")
	print("[ModelExporter] Total de CSGs coletados:", all_csgs.size())
	if all_csgs.size() == 0:
		print("[ModelExporter] Nenhum CSG encontrado para exportar!")
		emit_signal("export_complete", false, "Nenhum CSG encontrado para exportar!")
		return
	# Exportar todos os CSGs juntos para um único OBJ
	var success = csg_exporter.export_multiple_csgs_to_obj(all_csgs, file_path)
	emit_signal("export_complete", success, "Exportação finalizada para OBJ único." if success else "Erro ao exportar OBJ único.")

# Função auxiliar para coletar todos os CSGs recursivamente
func _collect_csgs_recursive(node: Node) -> Array:
	var csgs = []
	if node is CSGShape3D:
		csgs.append(node)
	for child in node.get_children():
		csgs += _collect_csgs_recursive(child)
	return csgs
