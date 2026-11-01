extends CanvasLayer	

@onready var video_player: VideoStreamPlayer = $VideoPlayer
@export var ending_videos: Dictionary[EventBus.EndingType, VideoStream] = {}
# Called when the node enters the scene tree for the first time.
var current_ending: EventBus.EndingType
func _ready() -> void:
	video_player.visible = false
	EventBus.cutscene_ending.connect(play_cutscene)
	video_player.finished.connect(_on_animation_player_finished)

func play_cutscene(ending_type: EventBus.EndingType) -> void:
	var ending_name = EventBus.EndingType.keys()[ending_type]
	if ending_videos.has(ending_type) and ending_videos[ending_type] != null:
		current_ending = ending_type
		video_player.stream = ending_videos[ending_type]
		video_player.visible = true
		video_player.play()
	else:
		push_error("Video untuk ending '" + ending_name + "' belum dimasukkan di Inspector!")
	


func _on_animation_player_finished() -> void:
	video_player.visible = false
	EventBus.game_ended.emit("Yeayyyy")
