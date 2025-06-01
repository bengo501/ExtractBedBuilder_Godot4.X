extends Node3D

var grid_mesh: MeshInstance3D
var axes_mesh: MeshInstance3D
var grid_visible := true
var axes_visible := true

const GRID_SIZE := 10
const GRID_STEP := 1
const AXIS_LENGTH := 5

func _ready():
	_create_grid()
	_create_axes()
	_update_visibility()

func _create_grid():
	if grid_mesh:
		remove_child(grid_mesh)
	grid_mesh = MeshInstance3D.new()
	var mesh = ImmediateMesh.new()
	mesh.surface_begin(Mesh.PRIMITIVE_LINES)
	for i in range(-GRID_SIZE, GRID_SIZE + 1):
		# Linhas paralelas ao eixo X
		mesh.surface_set_color(Color(0.7, 0.7, 0.7, 0.5))
		mesh.surface_add_vertex(Vector3(i * GRID_STEP, 0, -GRID_SIZE * GRID_STEP))
		mesh.surface_add_vertex(Vector3(i * GRID_STEP, 0, GRID_SIZE * GRID_STEP))
		# Linhas paralelas ao eixo Z
		mesh.surface_set_color(Color(0.7, 0.7, 0.7, 0.5))
		mesh.surface_add_vertex(Vector3(-GRID_SIZE * GRID_STEP, 0, i * GRID_STEP))
		mesh.surface_add_vertex(Vector3(GRID_SIZE * GRID_STEP, 0, i * GRID_STEP))
	mesh.surface_end()
	grid_mesh.mesh = mesh
	add_child(grid_mesh)

func _create_axes():
	if axes_mesh:
		remove_child(axes_mesh)
	axes_mesh = MeshInstance3D.new()
	var mesh = ImmediateMesh.new()
	mesh.surface_begin(Mesh.PRIMITIVE_LINES)
	# Eixo X (vermelho)
	mesh.surface_set_color(Color(1, 0, 0))
	mesh.surface_add_vertex(Vector3.ZERO)
	mesh.surface_add_vertex(Vector3(AXIS_LENGTH, 0, 0))
	# Eixo Y (verde)
	mesh.surface_set_color(Color(0, 1, 0))
	mesh.surface_add_vertex(Vector3.ZERO)
	mesh.surface_add_vertex(Vector3(0, AXIS_LENGTH, 0))
	# Eixo Z (azul)
	mesh.surface_set_color(Color(0, 0, 1))
	mesh.surface_add_vertex(Vector3.ZERO)
	mesh.surface_add_vertex(Vector3(0, 0, AXIS_LENGTH))
	mesh.surface_end()
	axes_mesh.mesh = mesh
	add_child(axes_mesh)

func show_grid():
	grid_visible = true
	_update_visibility()

func hide_grid():
	grid_visible = false
	_update_visibility()

func show_axes():
	axes_visible = true
	_update_visibility()

func hide_axes():
	axes_visible = false
	_update_visibility()

func _update_visibility():
	if grid_mesh:
		grid_mesh.visible = grid_visible
	if axes_mesh:
		axes_mesh.visible = axes_visible 