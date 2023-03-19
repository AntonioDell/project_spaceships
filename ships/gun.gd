class_name Gun
extends Node3D


@export var bullet_scene: PackedScene

@onready var _cooldown_timer := $CooldownTimer


func fire(bullet_direction: Vector2, bullet_rotation = Vector3.ZERO):
	if not _cooldown_timer.is_stopped(): return
	_cooldown_timer.start()
	
	var bullet = bullet_scene.instantiate() as Node3D
	if "direction" in bullet:
		bullet.direction = bullet_direction
	get_parent().add_sibling(bullet)
	bullet.global_position = global_position
	bullet.global_rotation = bullet_rotation
