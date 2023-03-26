class_name BarrelRollComponent
extends Node


signal barrel_roll_started()
signal barrel_roll_progress(new_velocity: Vector3, roll_rotation: Vector3)
signal barrel_roll_ended(acceleration: Vector2)


@export var duration := .25:
	set(new_value):
		duration = new_value
		$Timer.wait_time = duration
@export var cooldown := 2.0


var _current_rotation := 0.0
var _roll_speed := 0.0
var _new_velocity := Vector3.ZERO
var _acceleration := Vector3.ZERO
var _roll_direction := Vector3.ZERO
@onready var _velocity_component := $VelocityComponent as VelocityComponent


func do_a_barrel_roll(direction: Vector3):
	if not $Timer.is_stopped(): return
	_roll_direction = direction.normalized()
	_current_rotation = 0.0
	_new_velocity = Vector3.ZERO
	_velocity_component.is_disabled = false
	_velocity_component.direction = _roll_direction
	_velocity_component.reset_motion()
	emit_signal("barrel_roll_started")
	$Timer.wait_time = duration
	$Timer.start()


func _physics_process(delta):
	if $Timer.is_stopped(): return
	if _roll_speed == 0:
		_roll_speed = 360.0 / (duration / delta)
	
	if _roll_direction.x > 0:
		_current_rotation += _roll_speed
	else:
		_current_rotation -= _roll_speed
	emit_signal("barrel_roll_progress", _new_velocity, Vector3(0, _current_rotation,0))


func _on_velocity_changed(new_velocity: Vector3, acceleration: Vector3):
	_new_velocity = new_velocity
	_acceleration = acceleration


func _finish_roll():
	_velocity_component.direction = Vector3.ZERO
	_velocity_component.is_disabled = true
	emit_signal("barrel_roll_ended", _acceleration)



