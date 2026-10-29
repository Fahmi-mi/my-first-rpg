extends CanvasLayer

@onready var vignette: TextureRect = $Vignette
var active_tween: Tween

func _ready() -> void:
	vignette.modulate.a = 0.0
	EventBus.whisper_effect_triggered.connect(_on_whisper_effect)
	
func _on_whisper_effect(color: Color, duration: float) -> void:
	if active_tween and active_tween.is_valid():
		active_tween.kill()
		
	vignette.modulate = color
	vignette.modulate.a = 0.0
	
	active_tween = create_tween()
	# fade in (0.4 second)
	active_tween.tween_property(vignette, "modulate:a", color.a, 0.4)
	# hold duration
	active_tween.tween_interval(max(0.1, duration - 0.8))
	# fade out (0.6 second)
	active_tween.tween_property(vignette, "modulate:a", 0.0, 0.6)
