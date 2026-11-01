@tool
extends Node3D

@export_group("Trees")
## Drag your tree scenes/.glb files here (pohon1, pohon2).
@export var tree_scenes: Array[PackedScene]
## Same order as tree_scenes. Higher number = more of that tree.
@export var tree_weights: PackedFloat32Array = [1.0, 1.0]

@export var base_y: float = 0.0   # trees start at this height
@export var tree_scale: float = 2.5

@export_group("Area")
## The green floor (your Floor node). Its size defines the area.
@export var floor_node: VisualInstance3D
## Keep trees this far away from the floor's edge.
@export var edge_margin: float = 5.0
## Nodes where no trees should grow (town, bandara, Mountain...).
@export var exclusion_nodes: Array[Node3D]
@export var exclusion_margin: float = 3.0
## Height offset from the top of the floor (negative sinks the trunk in).
@export var y_offset: float = 0.0

@export_group("Scatter")
@export var count: int = 400
@export var min_spacing: float = 3.0
@export var random_seed: int = 1

@export_group("Clumping")
## Makes forest patches and clearings instead of an even spread.
@export var use_clumping: bool = true
@export var noise_frequency: float = 0.02
## Higher = fewer trees, bigger clearings.
@export_range(-1.0, 1.0) var noise_threshold: float = -0.1

@export_group("Rotation")
@export var random_yaw: bool = true
@export_range(0.0, 15.0) var max_tilt_deg: float = 0.0

@export_group("Collision")
@export var make_collision: bool = true

@export_group("")
@export var generate_now: bool = false:
	set(value):
		generate_now = false  # springs back so you can click again
		if value and is_inside_tree():
			generate()


func _own(n: Node) -> void:
	# Makes the node show in the Scene panel and get saved with the scene
	if Engine.is_editor_hint() and is_inside_tree():
		n.owner = get_tree().edited_scene_root


func generate() -> void:
	_clear()
	if floor_node == null or tree_scenes.is_empty():
		push_warning("TreeScatter: set floor_node and tree_scenes first.")
		return

	var rng := RandomNumberGenerator.new()
	rng.seed = random_seed

	var noise := FastNoiseLite.new()
	noise.seed = random_seed
	noise.frequency = noise_frequency

	# Area = top surface of the floor, minus the edge margin
	var fb := _global_aabb(floor_node)
	var min_x := fb.position.x + edge_margin
	var max_x := fb.end.x - edge_margin
	var min_z := fb.position.z + edge_margin
	var max_z := fb.end.z - edge_margin
	var ground_y := base_y + y_offset

	# Exclusion zones (top-down rectangles)
	var excluded: Array[Rect2] = []
	for n in exclusion_nodes:
		if n == null:
			continue
		var b := _global_aabb(n)
		if b.size == Vector3.ZERO:
			continue
		excluded.append(Rect2(b.position.x, b.position.z, b.size.x, b.size.z).grow(exclusion_margin))

	# One list of transforms per tree type
	var placements: Array = []
	for i in tree_scenes.size():
		placements.append([])

	var grid := {}  # spatial hash for the spacing check
	var cell := maxf(min_spacing, 0.01)
	var tilt := deg_to_rad(max_tilt_deg)
	var placed := 0
	var attempts := 0
	var max_attempts := count * 60

	while placed < count and attempts < max_attempts:
		attempts += 1
		var x := rng.randf_range(min_x, max_x)
		var z := rng.randf_range(min_z, max_z)

		if _in_excluded(x, z, excluded):
			continue
		if use_clumping and noise.get_noise_2d(x, z) < noise_threshold:
			continue
		if not _spacing_ok(x, z, grid, cell):
			continue

		var yaw := rng.randf_range(0.0, TAU) if random_yaw else 0.0
		var rot := Basis.from_euler(Vector3(rng.randf_range(-tilt, tilt), yaw, rng.randf_range(-tilt, tilt)))
		rot = rot.scaled(Vector3.ONE * tree_scale)
		var type_index := _pick_type(rng)
		placements[type_index].append(Transform3D(rot, Vector3(x, ground_y, z)))

		var key := Vector2i(floori(x / cell), floori(z / cell))
		if not grid.has(key):
			grid[key] = []
		grid[key].append(Vector2(x, z))
		placed += 1

	if placed < count:
		push_warning("TreeScatter: only fit %d of %d trees. Lower min_spacing/threshold or enlarge the area." % [placed, count])

	var body: StaticBody3D = null
	if make_collision:
		body = StaticBody3D.new()
		body.name = "TreeCollision"
		body.set_meta("generated", true)
		add_child(body)
		_own(body)

	for i in tree_scenes.size():
		if tree_scenes[i] != null and not placements[i].is_empty():
			_build_type(tree_scenes[i], placements[i], body)


func _build_type(scene: PackedScene, xforms: Array, body: StaticBody3D) -> void:
	var proto := scene.instantiate()
	var inv := global_transform.affine_inverse()

	# One MultiMesh per mesh in the tree (trunk and leaves can be separate meshes)
	for node in proto.find_children("*", "MeshInstance3D", true, false):
		var mi := node as MeshInstance3D
		if mi.mesh == null:
			continue
		var rel := _relative_xf(mi, proto)
		var mm := MultiMesh.new()
		mm.transform_format = MultiMesh.TRANSFORM_3D
		mm.mesh = mi.mesh
		mm.instance_count = xforms.size()
		for k in xforms.size():
			mm.set_instance_transform(k, inv * xforms[k] * rel)
		var inst := MultiMeshInstance3D.new()
		inst.multimesh = mm
		inst.set_meta("generated", true)
		add_child(inst)
		_own(inst)

	# Reuse the collision shapes that already exist inside the tree scene
	if body != null:
		for node in proto.find_children("*", "CollisionShape3D", true, false):
			var cs := node as CollisionShape3D
			if cs.shape == null:
				continue
			var rel := _relative_xf(cs, proto)
			var shape := _scaled_shape(cs.shape, tree_scale * rel.basis.get_scale().x)
			for xf in xforms:
				var t: Transform3D = inv * xf * rel
				var c := CollisionShape3D.new()
				c.shape = shape  # one scaled copy shared by all trees of this type
				c.transform = Transform3D(t.basis.orthonormalized(), t.origin)
				body.add_child(c)
				_own(c)
	proto.free()


func _clear() -> void:
	for c in get_children():
		if c.has_meta("generated"):
			remove_child(c)
			c.queue_free()


func _pick_type(rng: RandomNumberGenerator) -> int:
	var total := 0.0
	for i in tree_scenes.size():
		total += _weight(i)
	var r := rng.randf() * total
	for i in tree_scenes.size():
		r -= _weight(i)
		if r <= 0.0:
			return i
	return tree_scenes.size() - 1


func _weight(i: int) -> float:
	return tree_weights[i] if i < tree_weights.size() else 1.0


func _spacing_ok(x: float, z: float, grid: Dictionary, cell: float) -> bool:
	if min_spacing <= 0.0:
		return true
	var cx := floori(x / cell)
	var cz := floori(z / cell)
	var min_sq := min_spacing * min_spacing
	for dx in range(-1, 2):
		for dz in range(-1, 2):
			var key := Vector2i(cx + dx, cz + dz)
			if grid.has(key):
				for q: Vector2 in grid[key]:
					if (q - Vector2(x, z)).length_squared() < min_sq:
						return false
	return true


func _in_excluded(x: float, z: float, excluded: Array[Rect2]) -> bool:
	for r in excluded:
		if r.has_point(Vector2(x, z)):
			return true
	return false


func _global_aabb(node: Node) -> AABB:
	var result := AABB()
	var found := false
	var nodes: Array[Node] = [node]
	nodes.append_array(node.find_children("*", "VisualInstance3D", true, false))
	for n in nodes:
		if n is VisualInstance3D:
			var box: AABB = n.global_transform * n.get_aabb()
			result = box if not found else result.merge(box)
			found = true
	return result


func _relative_xf(node: Node3D, root: Node) -> Transform3D:
	var xf := Transform3D.IDENTITY
	var n: Node = node
	while n != null and n != root:
		xf = (n as Node3D).transform * xf
		n = n.get_parent()
	return xf

func _scaled_shape(shape: Shape3D, s: float) -> Shape3D:
	if is_equal_approx(s, 1.0):
		return shape
	var r = shape.duplicate()
	if r is BoxShape3D:
		r.size *= s
	elif r is SphereShape3D:
		r.radius *= s
	elif r is CapsuleShape3D or r is CylinderShape3D:
		r.radius *= s
		r.height *= s
	elif r is ConvexPolygonShape3D:
		var pts: PackedVector3Array = r.points
		for i in pts.size():
			pts[i] *= s
		r.points = pts
	elif r is ConcavePolygonShape3D:
		var faces: PackedVector3Array = r.get_faces()
		for i in faces.size():
			faces[i] *= s
		r.set_faces(faces)
	else:
		push_warning("TreeScatter: collision shape type not scaled: " + r.get_class())
	return r
