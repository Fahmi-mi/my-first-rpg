extends RigidBody3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func check_valid(item: ItemData) -> String:
	if !item:
		return "Need something to start machine"
	elif item.item_name == "Fuel":
		return "You can start machine"
	else:
		return "Need something to start machine"

func trigger_quest(item: ItemData) -> void:
	if !item:
		return
	print(item.item_name)
	if item.item_name == "Fuel":
		EventBus.cutscene_ending.emit(EventBus.EndingType.TRUE_ENDING)
	else:
		return
