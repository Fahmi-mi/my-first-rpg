extends CanvasLayer

@onready var countdown_label: Label = %CountdownLabel
@onready var timer: Timer = $Timer
var rng = RandomNumberGenerator.new()
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()
	EventBus.interact_save_ui.connect(interaction_on_save)
	timer.start(random_timer_countdown())

func _process(delta: float) -> void:
	countdown_label.text = "%02d:%02d" % time_left_to_save()

func interaction_on_save() -> void:
	if visible:
		hide()
	else:
		show()

func time_left_to_save():
	var time_left = timer.time_left
	var minute = floor(time_left / 60)
	var second = int(time_left) % 60
	return [minute, second]

func random_timer_countdown() -> float:
	return rng.randf_range(45, 90)

func _on_timer_timeout() -> void:
	EventBus.save_triggered.emit()
	timer.start(random_timer_countdown())
