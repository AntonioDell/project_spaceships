extends CharacterBody3D


enum {MOVE, FIND_TARGET, AIM, SHOOT, EXIT_SCREEN}


var _state = FIND_TARGET


@onready var _follow_curve_component := $follow_curve_component as FollowCurveComponent
@onready var _gun := $gun as Gun
@onready var _target_finder := $nearest_target_finder_component as NearestTargetFinder
@onready var _health_tracker_component := $health_tracker_component as HealthTrackerComponent


func _process(delta):
	match _state:
		MOVE: _follow_curve_component.start_follow()
		FIND_TARGET: 
			_target_finder.find_nearest_target(global_position)
			_state = AIM
		AIM: _rotate_towards_target(delta) 
		SHOOT: _shoot()
		EXIT_SCREEN: 
			_follow_curve_component.stop_follow()
			queue_free()


func _on_target_lost():
	_state = FIND_TARGET

func _rotate_towards_target(delta: float):
	if not _target_finder.target: 
		_state = FIND_TARGET
		return
	var target_position := _target_finder.target.global_position
	
	var own_position_2d = Vector2(global_position.x, global_position.y)
	var target_position_2d = Vector2(target_position.x, target_position.y)
	var direction = target_position_2d - own_position_2d

	var target_angle = atan2(direction.y, direction.x)
	var current_angle = global_rotation.z
	var necessary_rotation = wrapf(target_angle - current_angle, -PI, PI)

	var angular_speed = TAU * .5
	print("Target position %s, own position %s, necessary_rotation %s" % [target_position, global_position, rad_to_deg(necessary_rotation)])
	global_rotation.z = lerp_angle(global_rotation.z, global_rotation.z + necessary_rotation, delta * angular_speed)
	if necessary_rotation == global_rotation.z:
		print("Rotate finished")



func _shoot():
	var target_direction = Vector2(\
		_target_finder.target.global_position.x,\
		_target_finder.target.global_position.y)
	_gun.fire(target_direction)
	_state = MOVE
	


func _on_health_depleted():
	queue_free()


func _on_screen_exited():
	queue_free()


func _on_damage_received(damage: Damage):
	_health_tracker_component.change_health(-damage.amount)
