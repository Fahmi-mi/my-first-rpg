extends CanvasLayer

@export var trigger_chance: float = 0.5
@export var code_length: int = 5

const CHAR_POOL: String = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz23456789"
var target_code: String = ""

@onready var target_label: Label = $MarginContainer/MainPanel/TitleLabel #$CenterContainer/PanelContainer/MarginContainer/VBoxContainer/CodeDisplayPanel/TargetCodeLabel
@onready var input_line_edit: LineEdit = $MarginContainer/MainPanel/Input #$CenterContainer/PanelContainer/MarginContainer/VBoxContainer/InputLineEdit
@onready var error_label: Label = $MarginContainer/MainPanel/ErrorLabel #$CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ErrorLabel
@onready var submit_button: Button = $MarginContainer/MainPanel/Button  #$CenterContainer/PanelContainer/MarginContainer/VBoxContainer/SubmitButton

func _ready() -> void:
	hide()
	error_label.text = ""
	
	submit_button.pressed.connect(_verify_input)
	input_line_edit.text_submitted.connect(func(_text): _verify_input())
	
	EventBus.interaction_attempted.connect(_on_interaction_attempted)
	
func _on_interaction_attempted(_interactable_name: String) -> void:
	if visible:
		return
		
	if randf() <= trigger_chance:
		show_captcha()
		
func show_captcha() -> void:
	_generate_new_code()
	error_label.text = ""
	input_line_edit.text = ""
	
	show()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	input_line_edit.grab_focus()
	
	EventBus.captcha_triggered.emit()
	
func _generate_new_code() -> void:
	target_code = ""
	for i in range(code_length):
		var random_index: int = randi() % CHAR_POOL.length()
		target_code += CHAR_POOL[random_index]
	target_label.text = target_code
	
func _verify_input() -> void:
	var user_input: String = input_line_edit.text.strip_edges()
	if user_input == target_code:
		hide()
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		EventBus.captcha_resolved.emit(true)
	else:
		error_label.text = "CAPTCHA Verification Failed, Please Try Again"
		input_line_edit.text = ""
		_generate_new_code()
		input_line_edit.grab_focus()
