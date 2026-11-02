extends RigidBody3D

var is_active: bool
var unique_id: String = ""
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	unique_id = str(get_path())
	is_active = unique_id in SaveSystem.content_to_save.activate_radio

func interact() -> void:
	if is_active:
		return
	else:
		print("nyala euy")
		set_radio_active_state()
		print(is_active)
		EventBus.on_radio_activated.emit(unique_id)

func set_radio_active_state() -> void:
	is_active = true
	# Kalo ada kebutuhan ui berubah implemen disini
