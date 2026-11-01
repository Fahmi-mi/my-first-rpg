extends CharacterBody3D

@export var move_speed: float = 3.5
@export var attack_damage: float = 15
@export var attack_range: float = 1.8
@export var attack_cooldown: float = 1.2

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var player: CharacterBody3D = null
var can_attack: bool = true
var unique_id: String

@onready var health_component: HealthComponent = $HealthComponent
@onready var visuals: Node3D = $Visuals
@onready var weapon_holder: Node3D = $Visuals/HandHolder

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player") as CharacterBody3D
	unique_id = str(get_path())
	
	health_component.died.connect(_on_died)
	health_component.damage_taken.connect(_on_damage_taken)
	
func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta
		
	if player == null or not health_component.is_alive():
		velocity.x = move_toward(velocity.x, 0, move_speed)
		velocity.z = move_toward(velocity.z, 0, move_speed)
		move_and_slide()
		return
		
	var dist_to_player: float = global_position.distance_to(player.global_position)
	var look_pos: Vector3 = Vector3(player.global_position.x, global_position.y, player.global_position.z)
	look_at(look_pos, Vector3.UP)
	
	if dist_to_player > attack_range:
		var dir: Vector3 = (player.global_position - global_position).normalized()
		dir.y = 0
		velocity.x = dir.x * move_speed
		velocity.z = dir.z * move_speed
	else:
		velocity.x = move_toward(velocity.x, 0, move_speed)
		velocity.z = move_toward(velocity.z, 0, move_speed)
		
		if can_attack:
			_perform_attack()
			
	move_and_slide()
	
func _perform_attack() -> void:
	can_attack = false
	
	var tween: Tween = create_tween()
	tween.tween_property(weapon_holder, "rotation_degrees:x", -70.0, 0.15)
	tween.tween_property(weapon_holder, "rotation_degrees:x", 0.0, 0.25)
	
	if player and global_position.distance_to(player.global_position) <= (attack_range + 0.5):
		var player_health: HealthComponent = player.get_node_or_null("HealthComponent")
		if player_health:
			player_health.take_damage(attack_damage)
			
	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true
	
func _on_damage_taken(amount: int) -> void:
	print("[Enemy] Bleeding: %d! Remaining HP: %d" % [amount, health_component.current_health])
	
func _on_died() -> void:
	print("[Enemy] Enemy died")
	EventBus.enemy_defeated.emit(0)
	EventBus.on_enemy_killed.emit(unique_id)
	queue_free()
