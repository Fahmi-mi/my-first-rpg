extends Node

const VOICE_DIR: String = "res://assets/audio/voices/"
const EXTENSIONS: Array[String] = [".ogg", ".wav", ".mp3"]

var audio_player: AudioStreamPlayer
# cache for loaded audio files
var voice_clips: Dictionary = {}
# voice events that have been triggered
var triggered_events: Dictionary = {}

func _ready() -> void:
	audio_player = AudioStreamPlayer.new()
	audio_player.bus = "Master"
	add_child(audio_player)
	
	EventBus.voice_triggered.connect(func(key: String): play_voice(key))

func play_voice(trigger_key: String, only_once: bool = true) -> void:
	if only_once and triggered_events.has(trigger_key):
		return
		
	var stream: AudioStream = _get_or_load_stream(trigger_key)
	if stream != null:
		audio_player.stream = stream
		audio_player.play()
	else:
		print("[VoiceManager] '%s' called (no audio file found in %s)" % [trigger_key, VOICE_DIR])
		
	triggered_events[trigger_key] = true

# auto load from folder by key name
func _get_or_load_stream(key: String) -> AudioStream:
	if voice_clips.has(key):
		return voice_clips[key]
		
	for ext in EXTENSIONS:
		var path: String = VOICE_DIR + key + ext
		if ResourceLoader.exists(path):
			var stream: AudioStream = load(path)
			voice_clips[key] = stream
			return stream
			
	return null

# ex:
# VoiceManager.play_voice("first_walk")
# VoiceManager.play_voice("first_interaction")
