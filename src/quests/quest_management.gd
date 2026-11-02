extends Node

var enemy_killed: Array[String] = []
var activate_radio: Array[String] = []
func _ready() -> void:
	EventBus.on_enemy_killed.connect(trigger_sovereign_quest)
	EventBus.on_radio_activated.connect(trigger_popular_quest)
	EventBus.save_triggered.connect(_on_save_triggered)
	load_game()


func trigger_sovereign_quest(enemy_id: String) -> void:
	enemy_killed.append(enemy_id)
	if enemy_killed.size() >= 10:
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
	
func load_game():
	enemy_killed.assign(SaveSystem.content_to_save["enemy_killed"])
	activate_radio.assign(SaveSystem.content_to_save["activate_radio"])


func _on_save_triggered() -> void:
	SaveSystem.content_to_save.activate_radio = activate_radio
	SaveSystem.content_to_save.enemy_killed = enemy_killed
	SaveSystem._save()
