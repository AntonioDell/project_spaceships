extends CharacterBody3D

enum { MOVE, EXIT_SCREEN }


@export var move_direction := Vector3.DOWN:
	set(new_direction):
		move_direction = new_direction.normalized()


var _state = MOVE
@onready var _follow_curve_component := $follow_curve_component as FollowCurveComponent
@onready var _visible_on_screen_notifier := $VisibleOnScreenNotifier3D


func _ready():
	var move_curve := Curve3D.new()
	move_curve.add_point(Vector3.ZERO)
	move_curve.add_point(move_direction * 100)
	_follow_curve_component.curve = move_curve


func _process(delta):
	match _state:
		MOVE: _follow_curve_component.start_follow()
		EXIT_SCREEN: 
			_follow_curve_component.stop_follow()
			queue_free()


func _on_screen_exited():
	_state = EXIT_SCREEN
