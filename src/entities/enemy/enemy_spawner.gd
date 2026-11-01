@tool
extends Node3D

@export_group("Enemies")
## Drag your three enemy scenes here.
@export var enemy_scenes: Array[PackedScene]
## How many of each, same order as enemy_scenes.
@export var counts: PackedInt32Array = [10, 10, 10]

@export_group("Area")
## Whole map = your Floor node.
@export var floor_node: VisualInstance3D
@export var edge_margin: float = 5.0
@export var base_y: float = 0.0
## Buildings and other places to keep enemies out of (town, bandara, Mountain...).
@export var exclusion_nodes: Array[Node3D]
@export var exclusion_margin: float = 3.0
## Minimum distance between enemies.
@export var min_spacing: float = 4.0

@export_group("Scale")
@export var scale_min: float = 1.0
@export var scale_max: float = 2.0
## Most enemies end up near this value.
@export var scale_common: float = 1.5
## Smaller = more enemies close to scale_common.
@export var scale_spread: float = 0.2

@export_group("Random")
@export var random_seed: int = 1
@export var random_yaw: bool = true

@export_group("")
## Respawn everything with a new random layout each time the game starts.
@export var randomize_on_start: bool = true
@export var generate_now: bool = false:
	set(value):
		generate_now = false
		if value and is_inside_tree():
			generate()

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	# Freeze this node and all its enemies until the CSG floor has its collision
	process_mode = Node.PROCESS_MODE_DISABLED
	for i in 10:
		await get_tree().physics_frame
	if randomize_on_start:
		random_seed = randi()
		generate()
	process_mode = Node.PROCESS_MODE_INHERIT

func generate() -> void:
	_clear()
	if floor_node == null or enemy_scenes.is_empty():
		push_warning("EnemySpawner: set floor_node and enemy_scenes first.")
		return

	var rng := RandomNumberGenerator.new()
	rng.seed = random_seed

	var fb := _global_aabb(floor_node)
	var min_x := fb.position.x + edge_margin
	var max_x := fb.end.x - edge_margin
	var min_z := fb.position.z + edge_margin
	var max_z := fb.end.z - edge_margin

	var excluded: Array[Rect2] = []
	for n in exclusion_nodes:
		if n == null:
			continue
		var b := _global_aabb(n)
		if b.size == Vector3.ZERO:
			continue
		excluded.append(Rect2(b.position.x, b.position.z, b.size.x, b.size.z).grow(exclusion_margin))

	var placed: Array[Vector2] = []
	var min_sq := min_spacing * min_spacing

	for i in enemy_scenes.size():
		if enemy_scenes[i] == null:
			continue
		var want := counts[i] if i < counts.size() else 0
		var done := 0
		var attempts := 0
		while done < want and attempts < want * 60:
			attempts += 1
			var p := Vector2(rng.randf_range(min_x, max_x), rng.randf_range(min_z, max_z))

			if _in_excluded(p, excluded):
				continue
			if _too_close(p, placed, min_sq):
				continue

			var s := clampf(rng.randfn(scale_common, scale_spread), scale_min, scale_max)
			var yaw := rng.randf_range(0.0, TAU) if random_yaw else 0.0

			var e := enemy_scenes[i].instantiate() as Node3D
			e.set_meta("generated", true)
			add_child(e)
			if Engine.is_editor_hint():
				e.owner = get_tree().edited_scene_root
			e.global_transform = Transform3D(
				Basis(Vector3.UP, yaw).scaled(Vector3.ONE * s),
				Vector3(p.x, base_y, p.y)
			)
			placed.append(p)
			done += 1

		if done < want:
			push_warning("EnemySpawner: only fit %d of %d for enemy %d. Lower min_spacing or the exclusions." % [done, want, i])


func _clear() -> void:
	for c in get_children():
		if c.has_meta("generated"):
			remove_child(c)
			c.queue_free()


func _in_excluded(p: Vector2, excluded: Array[Rect2]) -> bool:
	for r in excluded:
		if r.has_point(p):
			return true
	return false


func _too_close(p: Vector2, others: Array[Vector2], min_sq: float) -> bool:
	for q in others:
		if p.distance_squared_to(q) < min_sq:
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
