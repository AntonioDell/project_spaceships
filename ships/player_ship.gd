extends CharacterBody3D


@onready var _velocity_component := $velocity_component as VelocityComponent
@onready var _tilt_y_component := $tilt_y_component as TiltYComponent
@onready var _player_control_component := $player_control_component as PlayerControlComponent
@onready var _barrel_roll_component := $barrel_roll_component as BarrelRollComponent
@onready var _gun := $Gun as Gun


func _physics_process(delta):
	move_and_slide()


func _on_velocity_changed(new_velocity: Vector3, acceleration: Vector2):
	velocity = new_velocity
	_tilt_y_component.movement_direction = Vector2(new_velocity.x, new_velocity.y)


func _on_player_move(direction):
	_velocity_component.direction = direction


func _on_tilt_y_component_tilt_changed(tilt_rotation: Vector3):
	rotation_degrees = tilt_rotation


func _on_player_control_component_player_rolls():
	if _velocity_component.direction != Vector2.ZERO:
		_barrel_roll_component.do_a_barrel_roll(_velocity_component.direction)
		_velocity_component.reset_motion()


func _on_barrel_roll_started():
	_velocity_component.is_disabled = true
	_tilt_y_component.is_disabled = true


func _on_barrel_roll_ended(acceleration: Vector2):
	_velocity_component.is_disabled = false
	_tilt_y_component.is_disabled = false
	_velocity_component.reset_motion(velocity, acceleration)


func _on_barrel_roll_progress(new_velocity: Vector3, roll_rotation: Vector3):
	rotation_degrees = roll_rotation
	velocity = new_velocity
	


func _on_player_shoots():
	_gun.fire(Vector2(0, 1))
