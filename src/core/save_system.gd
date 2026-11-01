extends Node

const path_to_save = "user://SaveFile.json"

var content_to_save: Dictionary = {
	"position": {
		"x": 1.0,
		"y": 2.0,
		"z": 10.0
	},
	"inventory": [],
	"radio_activated": [],
	"enemy_killed": []
}

func _ready() -> void:
	_load()

func _save():
	var file = FileAccess.open_encrypted_with_pass(path_to_save, FileAccess.WRITE, 'RPGPEMENANG#1')
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
		content_to_save.radio_activated = save_data.radio_activated
		content_to_save.enemy_killed = save_data.enemy_killed
