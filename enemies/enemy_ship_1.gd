extends CharacterBody3D

enum { MOVE, SHOOT, EXIT_SCREEN }


@export var move_direction := Vector3.DOWN:
	set(new_direction):
		move_direction = new_direction.normalized()


var _state = MOVE
@onready var _follow_curve_component := $follow_curve_component as FollowCurveComponent
@onready var _gun := $Gun as Gun
@onready var _health_tracker_component := $health_tracker_component as HealthTrackerComponent


func _ready():
	var move_curve := Curve3D.new()
	move_curve.add_point(Vector3.ZERO)
	move_curve.add_point(move_direction * 100)
	_follow_curve_component.curve = move_curve


func _process(_delta):
	match _state:
		MOVE: _follow_curve_component.start_follow()
		SHOOT: 
			_gun.fire(Vector3.DOWN)
			_state = MOVE
		EXIT_SCREEN: 
			_follow_curve_component.stop_follow()
			queue_free()


func _on_screen_exited():
	_state = EXIT_SCREEN


func _on_shoot_cooldown_timeout():
	_state = SHOOT


func _on_damage_received(damage: Damage):
	_health_tracker_component.change_health(-damage.amount)


func _on_health_depleted():
	queue_free()


func _on_delay_passed():
	$ShootCooldown.start()
