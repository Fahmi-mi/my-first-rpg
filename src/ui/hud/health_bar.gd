extends CanvasLayer

@onready var progress_bar: ProgressBar = $MarginContainer/ProgressBar

func _ready() -> void:
	var health: HealthComponent = get_parent().get_node_or_null("HealthComponent")
	if health:
		health.health_changed.connect(_on_changed_health)
		progress_bar.max_value = health.max_health
		progress_bar.value = health.current_health
	else:
		push_warning("[HealthBar] HealthComponent not found in parent")
		
func _on_changed_health(current_hp: int, max_hp: int) -> void:
	progress_bar.max_value = max_hp
	progress_bar.value = current_hp
