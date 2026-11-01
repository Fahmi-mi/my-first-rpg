extends Node

const path_to_save = "user://SaveFile.json"

var content_to_save: Dictionary = {
	"position": {
		"x": 0.0,
		"y": 1.0,
		"z": 0.0
	},
	"inventory": [null, null, null, null],
	"activate_radio": [],
	"enemy_killed": []
}

func _ready() -> void:
	_load()

func _save():
	var file = FileAccess.open_encrypted_with_pass(path_to_save, FileAccess.WRITE, 'RPGPEMENANG#1')
	print(content_to_save.duplicate())
	file.store_var(content_to_save.duplicate())
	file.close()
	
func _load():
	if FileAccess.file_exists(path_to_save):
		var file = FileAccess.open_encrypted_with_pass(path_to_save,FileAccess.READ, 'RPGPEMENANG#1')
		var data = file.get_var()
		file.close()
		
		var save_data = data.duplicate()
		content_to_save.position = save_data.position
		content_to_save.inventory = save_data.inventory
		content_to_save.activate_radio = save_data.activate_radio
		content_to_save.enemy_killed = save_data.enemy_killed
		print(content_to_save)

func _on_game_restart() -> void:
	content_to_save.position.x = 0.0
	content_to_save.position.y = 1.0
	content_to_save.position.z = 0.0
	content_to_save.inventory = [null, null, null, null]
	content_to_save.activate_radio = []
	content_to_save.enemy_killed = []
	_save()
