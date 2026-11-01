extends Node

var enemy_killed: Array[String] = []
var activate_radio: Array[String] = []
func _ready() -> void:
	EventBus.on_enemy_killed.connect(trigger_sovereign_quest)
	EventBus.on_radio_activated.connect(trigger_popular_quest)

func trigger_sovereign_quest(enemy_id: String) -> void:
	print(enemy_killed.size())
	enemy_killed.append(enemy_id)
	if enemy_killed.size() >= 50:
		print(enemy_killed.size())
		EventBus.cutscene_ending.emit(EventBus.EndingType.SOVEREIGN_ENDING)
	else:
		print("Enemy still remain")

func trigger_popular_quest(radio_id: String) -> void:
	activate_radio.append(radio_id)
	if activate_radio.size() >= 4:
		EventBus.cutscene_ending.emit(EventBus.EndingType.POPULAR_ENDING)
	else:
		print("There's inactive radio") 

func is_enemy_dead(enemy_id: String) -> bool:
	return enemy_killed.has(enemy_id)

func is_radio_active(radio_id: String) -> bool:
	return activate_radio.has(radio_id)
