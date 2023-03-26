class_name VelocityComponent
extends Node


signal velocity_changed(new_velocity: Vector3, acceleration: Vector3)


@export var direction := Vector3.ZERO:
	set(new_value):
		direction = new_value.normalized()
@export var speed := 5.0
@export var acceleration_factor := 100.0
@export_exp_easing var acceleration_easing := 0.0
@export_exp_easing var deceleration_easing := 0.0
@export var is_disabled := false


var _velocity := Vector3.ZERO
var _current_acceleration := Vector3.ZERO


func reset_motion(velocity = Vector3.ZERO, acceleration = Vector3.ZERO):
	_velocity = velocity
	_current_acceleration = acceleration


func _physics_process(delta):
	if is_disabled: return
	
	
	_current_acceleration = _current_acceleration.move_toward(direction, acceleration_factor * delta)
	var easing = acceleration_easing if direction else deceleration_easing
	
	if easing != 0:
		_velocity.x = speed * ease(abs(_current_acceleration.x), easing) * sign(_current_acceleration.x)
		_velocity.y = speed * ease(abs(_current_acceleration.y), easing) * sign(_current_acceleration.y)
	else:
		_velocity = speed * _current_acceleration

	emit_signal("velocity_changed", _velocity, _current_acceleration)

