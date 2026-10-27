extends CharacterBody3D

@export var move_speed: float = 5.0
@export var jump_velocity: float = 4.5
@export var mouse_sensitivity: float = 0.002

@export var min_delay: float = 0.1
@export var max_delay: float = 0.35

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

var delay_timer: float = 0.0
var target_input_dir: Vector2 = Vector2.ZERO
var delayed_input_dir: Vector2 = Vector2.ZERO

var is_locked: bool = false

@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	EventBus.captcha_triggered.connect(func(): is_locked = true)
	EventBus.captcha_resolved.connect(func(_success): is_locked = false)
	
func _unhandled_input(event: InputEvent) -> void:
	if is_locked:
		return
		
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)
		head.rotate_x(-event.relative.y * mouse_sensitivity)
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89), deg_to_rad(89))
		
	if event.is_action_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			
	if event.is_action_pressed("interact"):
		EventBus.interaction_attempted.emit("test_object")

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta
		
	if is_locked:
		velocity.x = move_toward(velocity.x, 0, move_speed)
		velocity.z = move_toward(velocity.z, 0, move_speed)
		move_and_slide()
		return
		
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
		VoiceManager.play_voice("test_audio")
		
	var raw_input: Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	
	if raw_input != target_input_dir:
		target_input_dir = raw_input
		delay_timer = randf_range(min_delay, max_delay)
		
	if delay_timer > 0.0:
		delay_timer -= delta
		if delay_timer <= 0.0:
			delayed_input_dir = target_input_dir
	else:
		delayed_input_dir = target_input_dir
	
	var direction: Vector3 = (transform.basis * Vector3(delayed_input_dir.x, 0, delayed_input_dir.y)).normalized()
	
	if direction != Vector3.ZERO:
		velocity.x = direction.x * move_speed
		velocity.z = direction.z * move_speed
	else:
		velocity.x = move_toward(velocity.x, 0, move_speed)
		velocity.z = move_toward(velocity.z, 0, move_speed)
		
	move_and_slide()
