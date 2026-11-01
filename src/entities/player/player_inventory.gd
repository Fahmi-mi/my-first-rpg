class_name PlayerInventory
extends Node

var slots: Array = [null, null, null, null]
var active_slot_index: int = 0

func _ready() -> void:
	load_game()
	call_deferred("_update_ui")
	EventBus.save_triggered.connect(_on_save_triggered)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("slot_w"):
		_select_slot(0)
	elif event.is_action_pressed("slot_a"):
		_select_slot(1)
	elif event.is_action_pressed("slot_s"):
		_select_slot(2)
	elif event.is_action_pressed("slot_d"):
		_select_slot(3)
		
func _select_slot(index: int) -> void:
	active_slot_index = index
	_update_ui()
	EventBus.inventory_slot_selected.emit(active_slot_index)
	
func add_item(item: ItemData) -> bool:
	for i in range(slots.size()):
		if slots[i] == null:
			slots[i] = item
			_update_ui()
			return true
	return false
	
func spawn_item(item: ItemData):
	var interactable = item.interactable_scene.instantiate()
	interactable.item_data = item
	get_tree().current_scene.add_child(interactable)
	EventBus.item_drop.emit(interactable)
	
func drop_item():
	if slots[active_slot_index]:
		var dropped_item = slots[active_slot_index]
		spawn_item(dropped_item)
		slots[active_slot_index] = null
		_select_slot(active_slot_index)
		EventBus.inventory_updated.emit(slots)
		
func load_game():
	var loaded_inventory = SaveSystem.content_to_save["inventory"]
	var index = 0
	for i in loaded_inventory:
		if i != null and i is String:
			var loaded_item = load(i)
			slots[index] = loaded_item
		else:
			null
		index += 1

func _update_ui() -> void:
	EventBus.inventory_updated.emit(slots)
	
func _on_save_triggered() -> void:
	var saved_inventory = []
	for i in slots:
		if i != null:
			saved_inventory.append(i.resource_path)
		else:
			saved_inventory.append(null)
	SaveSystem.content_to_save.inventory = saved_inventory
	SaveSystem._save()
