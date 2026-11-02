extends CanvasLayer

@onready var slots_container: HBoxContainer = $MarginContainer/HBoxContainer

const COLOR_ACTIVE: Color = Color(1.0, 0.85, 0.0)
const COLOR_NORMAL: Color = Color(1.0, 1.0, 1.0, 0.5)

func _ready() -> void:
	EventBus.inventory_updated.connect(_on_inventory_updated)
	EventBus.inventory_slot_selected.connect(_on_slot_selected)
	_on_slot_selected(0)
	
func _on_inventory_updated(slots: Array) -> void:
	var slot_nodes: Array = slots_container.get_children()
	
	for i in range(slot_nodes.size()):
		var slot_node: PanelContainer = slot_nodes[i]
		var icon_rect: TextureRect = slot_node.get_node_or_null("TextureRect")
		
		if icon_rect:
			if i < slots.size() and slots[i] != null:
				icon_rect.texture = slots[i].icon
			else:
				icon_rect.texture = null
				
func _on_slot_selected(active_index: int) -> void:
	var slot_nodes: Array = slots_container.get_children()
	for i in range(slot_nodes.size()):
		if i == active_index:
			slot_nodes[i].modulate = COLOR_ACTIVE
		else:
			slot_nodes[i].modulate = COLOR_NORMAL
