extends Control

@onready var fps_label = $FPSLabel
@onready var memory_label = $MemoryLabel
@onready var objects_label = $ObjectsLabel

var update_interval = 0.5  # Update every 0.5 seconds
var time_passed = 0.0

func _ready():
	# Configure the labels
	fps_label.text = "FPS: --"
	memory_label.text = "Memory: --"
	objects_label.text = "Objects: --"
	
	# Set the position to bottom left
	position = Vector2(10, get_viewport_rect().size.y - 70)
	
	# Make sure the control stays on top
	process_mode = Node.PROCESS_MODE_ALWAYS

func _process(delta):
	time_passed += delta
	
	if time_passed >= update_interval:
		time_passed = 0
		
		# Update FPS
		var fps = Engine.get_frames_per_second()
		fps_label.text = "FPS: %d" % fps
		
		# Update memory usage (in MB)
		var mem = OS.get_static_memory_usage() / 1024.0 / 1024.0
		memory_label.text = "Memory: %.1f MB" % mem
		
		# Count CSG nodes in the scene
		var csg_count = 0
		var root = get_tree().root
		for node in root.get_children():
			if node is CSGShape3D:
				csg_count += 1
			csg_count += _count_csg_nodes(node)
		
		objects_label.text = "CSG: %d" % csg_count

func _count_csg_nodes(node: Node) -> int:
	var count = 0
	for child in node.get_children():
		if child is CSGShape3D:
			count += 1
		count += _count_csg_nodes(child)
	return count 