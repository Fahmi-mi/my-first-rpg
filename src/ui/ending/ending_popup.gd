extends CanvasLayer

@onready var title_label: Label = %TitleLabel
@onready var restart_button: Button = %Button

func _ready() -> void:
	hide()
	EventBus.game_ended.connect(the_ending_choosen) 
	restart_button.pressed.connect(restart_game)

func the_ending_choosen(ending: EventBus.EndingType) -> void:
	if ending == EventBus.EndingType.TRUE_ENDING:
		set_true_ending()
	elif ending == EventBus.EndingType.SOVEREIGN_ENDING:
		set_sovereign_ending()
	elif ending == EventBus.EndingType.POPULAR_ENDING:
		set_popular_ending()
	else:
		set_escape_ending()
	show()
	
func set_true_ending() -> void:
	title_label.text = "Tegar now can live peacefully"

func set_sovereign_ending() -> void:
	title_label.text ="Tegar now trying to be dictator of the world"

func set_popular_ending() -> void:
	title_label.text = "Tegar now looks so happy but deep inside her feelings feel so lonely"

func set_escape_ending() -> void:
	title_label.text = "Tegar now be more calm but always haunted by guilt"

func restart_game() -> void:
	SaveSystem._on_game_restart()
	get_tree().reload_current_scene()
