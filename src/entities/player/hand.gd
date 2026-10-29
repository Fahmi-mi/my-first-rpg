extends Node3D

var current_item_instance: Node3D = null
@onready var inventory: PlayerInventory = $"../../../Inventory"

func _ready() -> void:
	EventBus.inventory_slot_selected.connect(_update_held_item)

func clear_item():
	if current_item_instance:
		current_item_instance.queue_free()
		current_item_instance = null
		
func show_item(item: ItemData):
	clear_item()
	if item and item.mesh_scene:
		current_item_instance = item.mesh_scene.instantiate()
		current_item_instance.position = Vector3.ZERO
		current_item_instance.rotation = Vector3.ZERO
		add_child(current_item_instance)

func _update_held_item(slot_index: int):
	var item = inventory.slots[slot_index]
	show_item(item)
