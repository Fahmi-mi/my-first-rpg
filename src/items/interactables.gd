extends RigidBody3D
@export var item_data: ItemData
@onready var mesh_instance_node: MeshInstance3D = $MeshInstance3D

func _ready() -> void:
	name = item_data.item_name
	spawn_item(item_data.mesh_scene)
	
func interact(player: CharacterBody3D): 
	#var success: bool = PlayerInventory.add_items(item_data)
	EventBus.interaction_attempted.emit("Take a " + item_data.item_name)
	#if success:
		#queue_free()
	#else:
		#print("Item penuh")
		

func find_first_mesh_instance(node : Node) -> MeshInstance3D:
	if node is MeshInstance3D:
		return node
	for child in node.get_children():
		var result = find_first_mesh_instance(child)
		if result:
			return result
	return null
	
func spawn_item(scene) -> Node3D:
	var inst = scene.instantiate()
	var mesh_instance = find_first_mesh_instance(inst)
	if mesh_instance and mesh_instance.mesh:
		var shape = mesh_instance.mesh.create_convex_shape()
		var col_shape = CollisionShape3D.new()
		col_shape.shape = shape
		self.add_child(inst)
		self.add_child(col_shape)
	return inst
