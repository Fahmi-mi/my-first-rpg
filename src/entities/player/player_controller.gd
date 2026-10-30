extends CharacterBody3D

@export var move_speed: float = 5.0
@export var jump_velocity: float = 4.5
@export var mouse_sensitivity: float = 0.002

@export var min_delay: float = 0.1
@export var max_delay: float = 0.35
@onready var inventory: PlayerInventory = $Inventory

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

var delay_timer: float = 0.0
var target_input_dir: Vector2 = Vector2.ZERO
var delayed_input_dir: Vector2 = Vector2.ZERO

var is_locked: bool = false

@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D
@onready var see_cast: RayCast3D = %SeeCast
@onready var hand: Node3D = $Head/Camera3D/Hand
@onready var guide_canvas: CanvasLayer = $GuideCanvas
@onready var health_component: HealthComponent = $HealthComponent

func _ready() -> void:
	add_to_group("player")
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	EventBus.captcha_triggered.connect(func(): is_locked = true)
	EventBus.captcha_resolved.connect(func(_success): is_locked = false)
	EventBus.item_drop.connect(drop_from_player)
	
	health_component.damage_taken.connect(_on_damage_taken)
	health_component.died.connect(_on_died)
	
func _on_damage_taken(amount: int) -> void:
	print("[Player] Damage: %d, Remaining Health: %d/%d" % [amount, health_component.current_health, health_component.max_health])
	
func _on_died() -> void:
	print("[Player] You died")
	
func _unhandled_input(event: InputEvent) -> void:
	if is_locked:
		return
		
	#test damage and heal
	#if event is InputEventKey and event.pressed and event.keycode == KEY_K:
		#health_component.take_damage(20)
	#if event is InputEventKey and event.pressed and event.keycode == KEY_L:
		#health_component.heal(15)
		
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)
		head.rotate_x(-event.relative.y * mouse_sensitivity)
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89), deg_to_rad(89))
		
	if event.is_action_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	var object = see_cast.get_collider()
	# Visual Trigger
	if see_cast.is_colliding():
		if object.has_method("check_valid") and object.is_in_group("interactable"):
			var display = object.check_valid(
				inventory.slots[inventory.active_slot_index]
			)
			EventBus.guidance_text.emit(display)
		else:
			EventBus.stop_guidance_text.emit()
	else:
		EventBus.stop_guidance_text.emit()
	
	# Interact Trigger
	if event.is_action_pressed("interact"):
		if object == null:
			return 
		elif see_cast.is_colliding() and object.is_in_group("interactable"):				
			if object.has_method("interact"):
				if object.is_in_group("quest_item"):
					object.interact()
				else:
					inventory.add_item(object.item_data)
					inventory._select_slot(inventory.active_slot_index)
					object.free()
			elif object.has_method("trigger_quest"):
				object.trigger_quest(
					inventory.slots[inventory.active_slot_index]
				)
			else:
				print("Ga punya")

	if event.is_action_pressed("drop"):
		inventory.drop_item()
			

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
		#test audio function
		#VoiceManager.play_voice("test_audio")
		#test color filter audio
		VoiceManager.play_whisper("test_audio", VoiceManager.Personality.BRAVE, false)
		
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

func drop_from_player(item):
	var forward = -transform.basis.z.normalized()
	var drop_pos = global_position + forward * 2.0
	item.global_position = drop_pos
