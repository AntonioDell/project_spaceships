extends CharacterBody3D


enum State {MOVE_INTO_SCREEN, FIND_TARGET, CHASE_TARGET, SHOW_DAMAGE_AREA, EXPLODE}


var _state = State.MOVE_INTO_SCREEN


@onready var _follow_curve_component := $follow_curve_component as FollowCurveComponent
@onready var _visible_on_screen_notifier_3d := $VisibleOnScreenNotifier3D as VisibleOnScreenNotifier3D
@onready var _nearest_target_finder_component := $nearest_target_finder_component as NearestTargetFinder
@onready var _velocity_component := $velocity_component as VelocityComponent
@onready var _player_detect_area := $PlayerDetectArea as Area3D
@onready var _pulsating_orb := $PulsatingOrb as MeshInstance3D
@onready var _damager_component := $damager_component as DamagerComponent


func _physics_process(_delta: float):
	match _state:
		State.MOVE_INTO_SCREEN: _move_into_screen()
		State.FIND_TARGET: _find_target()
		State.CHASE_TARGET: _chase_target()
		State.SHOW_DAMAGE_AREA: _show_damage_area()
		State.EXPLODE: _explode()


func _move_into_screen():
	if _follow_curve_component.is_progressing: return 
	_follow_curve_component.start_follow()
	await _visible_on_screen_notifier_3d.screen_entered
	await get_tree().create_timer(5.0).timeout
	_follow_curve_component.stop_follow()
	if _state == State.MOVE_INTO_SCREEN:
		_state = State.FIND_TARGET


func _find_target():
	_nearest_target_finder_component.find_nearest_target(global_position)
	_state = State.CHASE_TARGET


func _on_target_lost():
	if _state >= State.SHOW_DAMAGE_AREA: return
	_state = State.FIND_TARGET


func _chase_target():
	var direction = _nearest_target_finder_component.target.global_position - global_position
	_velocity_component.direction = direction
	move_and_slide()


func _on_velocity_changed(new_velocity, acceleration):
	velocity = new_velocity


func _on_player_detect_area_entered(area):
	if _state > State.CHASE_TARGET: return
	if _state == State.MOVE_INTO_SCREEN:
		_follow_curve_component.stop_follow()
	_state = State.SHOW_DAMAGE_AREA

func _on_player_detect_area_body_entered(body):
	if _state > State.CHASE_TARGET: return
	if _state == State.MOVE_INTO_SCREEN:
		_follow_curve_component.stop_follow()
	_state = State.SHOW_DAMAGE_AREA


func _show_damage_area():
	var shader_material := _pulsating_orb.get_active_material(0) as ShaderMaterial
	shader_material.set_shader_parameter("is_visible",  true)
	_pulsating_orb.visible = true
	var pulsation_duration = shader_material.get_shader_parameter("pulsation_duration")
	await get_tree().create_timer(pulsation_duration).timeout
	_pulsating_orb.visible = false
	_state = State.EXPLODE


func _explode():
	# This not working... why
	_damager_component.is_disabled = false
	await get_tree().create_timer(.1).timeout
	queue_free()


func _on_damager_component_damage_dealt(damage: Damage):
	print(damage.amount)


