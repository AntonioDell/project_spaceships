class_name TiltYComponent
extends Node


signal tilt_changed(tilt_rotation: Vector3)


@export var max_tilt_degrees := 20.0
@export var tilt_speed := 100.0
@export var is_disabled := false


var movement_direction := Vector3.ZERO:
	set(new_value):
		movement_direction = new_value.normalized()


var _current_tilt := 0.0


func _physics_process(delta):
	if is_disabled: return
	
	if movement_direction.x == 0:
		_current_tilt = move_toward(_current_tilt, 0.0, delta * tilt_speed)
	elif movement_direction.x > 0:
		var new_tilt = _current_tilt + delta * tilt_speed
		_current_tilt =  minf(new_tilt, max_tilt_degrees)
	else:
		var new_tilt = _current_tilt - delta * tilt_speed
		_current_tilt =  maxf(new_tilt, -max_tilt_degrees)
		
	emit_signal("tilt_changed",Vector3(0, _current_tilt, 0))
