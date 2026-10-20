class_name PlayerInventory
extends Node

var slots: Array = [null, null, null, null]
var active_slot_index: int = 0

func _ready() -> void:
	call_deferred("_update_ui")

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
	
func _update_ui() -> void:
	EventBus.inventory_updated.emit(slots)
