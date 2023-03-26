class_name Gun
extends Node3D


@export var bullet_scene: PackedScene

@onready var _cooldown_timer := $CooldownTimer


func fire(bullet_direction: Vector3):
	if not _cooldown_timer.is_stopped(): return
	_cooldown_timer.start()
	
	var bullet = bullet_scene.instantiate() as Node3D
	if "direction" in bullet:
		bullet.direction = bullet_direction
	get_tree().root.add_child(bullet)
	bullet.global_position = global_position
