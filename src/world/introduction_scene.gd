extends Control

@export_file("*.tscn") var main_world_path: String = "res://src/world/main_world.tscn"
@onready var video_player: VideoStreamPlayer = $VideoStreamPlayer
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if SaveSystem.content_to_save.introduction_played:
		get_tree().change_scene_to_file.call_deferred(main_world_path)
		return
	else:
		video_player.finished.connect(on_video_finished)
		video_player.play()

func on_video_finished() -> void:
	SaveSystem.content_to_save.introduction_played = true
	SaveSystem._save()
	print(SaveSystem.content_to_save.introduction_played)
	get_tree().change_scene_to_file.call_deferred(main_world_path)
	return
