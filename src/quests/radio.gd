extends RigidBody3D

var is_active: bool
var unique_id: String = ""
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	is_active = false
	unique_id = str(get_path())

func interact() -> void:
	print(is_active)
	if is_active:
		return
	else:
		set_radio_active_state()
		EventBus.on_radio_activated.emit(unique_id)

func set_radio_active_state() -> void:
	is_active = true
	# Kalo ada kebutuhan ui berubah implemen disini
