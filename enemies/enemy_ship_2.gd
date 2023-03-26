extends Node3D


enum State { MOVE, FIND_TARGET, AIM, SHOOT, EXIT_SCREEN }


var _state = State.MOVE:
	set(new_value):
		if _state != new_value:
			print("State: %s" % State.keys()[new_value])
		_state = new_value

@onready var _follow_curve_component := $follow_curve_component as FollowCurveComponent
@onready var _gun := %Gun as Gun
@onready var _target_finder := $nearest_target_finder_component as NearestTargetFinder
@onready var _health_tracker_component := $health_tracker_component as HealthTrackerComponent
@onready var _rotate_toward_target_component := $rotate_toward_target_component as RotateTowardTargetComponent
@onready var _aim_timer := $AimTimer as Timer
@onready var _gun_cooldown_timer := $GunCooldownTimer as Timer
@onready var _visible_on_screen_notifier := $VisibleOnScreenNotifier3D as VisibleOnScreenNotifier3D


func _process(_delta):
	match _state:
		State.MOVE: _move()
		State.FIND_TARGET: _find_target()
		State.AIM: _aim() 
		State.SHOOT: _shoot()
		State.EXIT_SCREEN: 
			_follow_curve_component.stop_follow()
			queue_free()


func _move():
	_follow_curve_component.start_follow()
	if _gun_cooldown_timer.is_stopped():
		_gun_cooldown_timer.start()


func _on_gun_cooldown_timer_timeout():
	_state = State.FIND_TARGET


func _find_target():
	if not _visible_on_screen_notifier.is_on_screen():
		_state = State.MOVE
		return
	_target_finder.find_nearest_target(global_position)
	_state = State.AIM
	


func _aim():
	if _aim_timer.is_stopped():
		_aim_timer.start()
	_rotate_toward_target_component.start_rotation(_target_finder.target.global_position)


func _on_aim_timer_timeout():
	_state = State.SHOOT


func _shoot():
	_gun.fire(_target_finder.target.global_position - _gun.global_position)
	_state = State.MOVE


func _on_target_lost():
	_state = State.FIND_TARGET
	if not _aim_timer.is_stopped():
		_aim_timer.stop()


func _on_health_depleted():
	queue_free()


func _on_damage_received(damage: Damage):
	_health_tracker_component.change_health(-damage.amount)


func _on_screen_exited():
	queue_free()

