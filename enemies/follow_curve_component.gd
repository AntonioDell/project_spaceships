class_name FollowCurveComponent
extends Path3D


@export var progress_units_per_second := 1.0


var _is_progressing := false
@onready var _path_follow := $PathFollow3D


func start_follow():
	if _is_progressing or not curve: return
	var parent_to_reparent = get_parent_node_3d()
	reparent(parent_to_reparent.get_parent_node_3d())
	parent_to_reparent.reparent($PathFollow3D)
	_is_progressing = true


func stop_follow():
	if not _is_progressing: return
	_is_progressing = false
	var original_parent = $PathFollow3D.get_child(0)
	original_parent.reparent(get_parent_node_3d())
	reparent(original_parent)


func _physics_process(delta):
	if not _is_progressing: return
	
	_path_follow.progress += progress_units_per_second * delta
	
