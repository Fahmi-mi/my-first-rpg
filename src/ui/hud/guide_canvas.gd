extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EventBus.guidance_text.connect(show_guide)
	EventBus.stop_guidance_text.connect(stop_guide)


func show_guide(text: String):
	%GuideText.text = text

func stop_guide():
	%GuideText.text = ""
