class_name HealthTrackerComponent
extends Node


signal health_depleted()
signal health_changed(current_health: int, previous_health: int, max_health: int)


@export var max_health: int
@export var health: int


func change_health(amount: int):
	if(health == 0 and amount <= 0): return
	var previous_health = health
	health = clampi(health + amount, 0, max_health)
	
	emit_signal("health_changed", health, previous_health, max_health)
	
	if health == 0:
		emit_signal("health_depleted")
