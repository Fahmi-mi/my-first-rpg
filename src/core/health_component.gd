class_name HealthComponent
extends Node

signal health_changed(current_hp: int, max_hp: int)
signal damage_taken(amount: int)
signal healed(amount: int)
signal died

@export var max_health: int = 100
var current_health: int
var is_invulnerable: bool = false

func _ready() -> void:
	current_health = max_health
	call_deferred("_emit_health_changed")
	
func take_damage(amount: int) -> void:
	if amount <= 0 or is_invulnerable or current_health <= 0:
		return
		
	current_health = max(0, current_health - amount)
	damage_taken.emit(amount)
	_emit_health_changed()
	
	if current_health == 0:
		died.emit()
		
func heal(amount: int) -> void:
	if amount <= 0 or current_health <= 0:
		return
		
	current_health = min(max_health, current_health + amount)
	healed.emit(amount)
	_emit_health_changed()
	
func is_alive() -> bool:
	return current_health > 0
	
func _emit_health_changed() -> void:
	health_changed.emit(current_health, max_health)
