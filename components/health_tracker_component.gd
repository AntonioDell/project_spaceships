class_name HealthTrackerComponent
extends Node


signal health_depleted()


@export var max_health: int
@export var health: int


func change_health(amount: int):
	if(health == 0 and amount <= 0): return
	health = clampi(health + amount, 0, max_health)
	if health == 0:
		emit_signal("health_depleted")
