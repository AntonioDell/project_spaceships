extends Node3D


@export var direction:= Vector2.UP
var _motion := Vector3.ZERO
@onready var _velocity_component:= $VelocityComponent as VelocityComponent


func _ready():
	_velocity_component.direction = direction


func _physics_process(delta):
	global_position += _motion * delta


func _on_screen_exited():
	queue_free()


func _on_velocity_changed(new_velocity, _acceleration):
	_motion = Vector3(new_velocity.x, new_velocity.y, 0)


func _on_damager_component_damage_dealt(_damage):
	queue_free()
