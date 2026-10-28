extends RigidBody3D
@export var item_data: ItemData
@onready var mesh_instance_node: MeshInstance3D = $MeshInstance3D

func interact(player: CharacterBody3D): 
	var success: bool = player.Inventory.add_items(item_data)
	EventBus.interaction_attempted.emit("Take a " + item_data.item_name)
	if success:
		queue_free()
	else:
		print("Item penuh")
		


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
