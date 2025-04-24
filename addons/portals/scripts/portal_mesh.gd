@tool
extends ArrayMesh
class_name PortalMesh

@export_range(0.1, 10, 0.01) var height: float = 2.0:
	set(new_val):
		height = new_val
		generate_portal_mesh()
		
@export_range(0.1, 10, 0.01) var width: float = 1.0:
	set(new_val):
		width = new_val
		generate_portal_mesh()
	
## Player camera's NEAR clip distance
@export_range(0, 0.2, 0.001) var indent: float = 0.1:
	set(new_val):
		indent = new_val
		generate_portal_mesh()

func _init() -> void:
	if Engine.is_editor_hint():
		generate_portal_mesh()

func generate_portal_mesh() -> void:
	print("[PortalMesh] Creating mesh")
	var _start_time: int = Time.get_ticks_usec()
	clear_surfaces() # Reset

	var surface_array: Array = []
	surface_array.resize(Mesh.ARRAY_MAX)

	var verts: PackedVector3Array = PackedVector3Array()
	var uvs: PackedVector2Array = PackedVector2Array()
	var normals: PackedVector3Array = PackedVector3Array()
	var indices: PackedInt32Array = PackedInt32Array()

	# Just to save some chars
	var w: float = width / 2
	var h: float = height / 2


	# Outside rect
	var TOP_LEFT: Vector3 = Vector3(-w, h, 0)
	var TOP_RIGHT: Vector3 = Vector3(w, h, 0)
	var BOTTOM_LEFT: Vector3 = Vector3(-w, -h, 0)
	var BOTTOM_RIGHT: Vector3 = Vector3(w, -h, 0)
	# Inside rect, indented
	var INDENT_TL: Vector3 = TOP_LEFT + Vector3(indent, -indent, -indent)
	var INDENT_TR: Vector3 = TOP_RIGHT + Vector3(-indent, -indent, -indent)
	var INDENT_BL: Vector3 = BOTTOM_LEFT + Vector3(indent, indent, -indent)
	var INDENT_BR: Vector3 = BOTTOM_RIGHT + Vector3(-indent, indent, -indent)

	verts.append_array([
	TOP_LEFT, TOP_RIGHT, BOTTOM_LEFT, BOTTOM_RIGHT,
	INDENT_TL, INDENT_TR, INDENT_BL, INDENT_BR
	])

	var ix: float = indent / width
	var iy: float = indent / height
	uvs.append_array([
	Vector2(0, 0), Vector2(1, 0), Vector2(0, 1), Vector2(1, 1), # Outside UVs
	Vector2(ix, iy), Vector2(1-ix, iy), Vector2(ix, 1-iy), Vector2(1-ix, 1-iy) # Indented UVs
	])

	# We are going for a flat-surface look here. Portals should be unshaded anyways.
	normals.append_array([
	Vector3.BACK, Vector3.BACK, Vector3.BACK, Vector3.BACK,
	Vector3.BACK, Vector3.BACK, Vector3.BACK, Vector3.BACK
	])

	# 0 ----------- 1
	# | \         / |
	# |  4-------5  |
	# |  |       |  |
	# |  |       |  |
	# |  6-------7  |
	# | /         \ |
	# 2 ----------- 3

	# Triangles are clockwise!

	indices.append_array([
		0, 1, 4,
		4, 1, 5, # Top section done
		1, 3, 5,
		5, 3, 7, # right section done
		3, 2, 7,
		7, 2, 6, # bottom section done
		2, 0, 6,
		6, 0, 4, # left section done
	
		4, 5, 6,
		6, 5, 7, # middle sectiondone
	])

	surface_array[Mesh.ARRAY_VERTEX] = verts
	surface_array[Mesh.ARRAY_TEX_UV] = uvs
	surface_array[Mesh.ARRAY_NORMAL] = normals
	surface_array[Mesh.ARRAY_INDEX] = indices
	
	add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface_array)
	
	print("[PortalMesh] Done in %f ms" % [(Time.get_ticks_usec() - _start_time) / 1000.0])
	
