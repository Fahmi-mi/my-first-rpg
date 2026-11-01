extends Node3D

var current_item_instance: Node3D = null
var is_animating: bool = false
var base_position: Vector3 = Vector3.ZERO
var base_rotation: Vector3 = Vector3.ZERO

@onready var inventory: PlayerInventory = $"../../../Inventory"

func _ready() -> void:
	base_position = position
	base_rotation = rotation
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
	
func play_attack_animation() -> void:
	if is_animating:
		return
		
	is_animating = true
	var tween = create_tween()
	tween.tween_property(self, "rotation_degrees:x", base_rotation.x - 45.0, 0.08)
	tween.parallel().tween_property(self, "position:z", base_position.z - 0.15, 0.08)
	tween.chain().tween_property(self, "rotation_degrees:x", base_rotation.x, 0.12)
	tween.parallel().tween_property(self, "position:z", base_position.z, 0.12)
	tween.finished.connect(func(): is_animating = false)
