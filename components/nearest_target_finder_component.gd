class_name NearestTargetFinder
extends Node


signal target_lost


@export_enum("Player", "Enemy", "All") var target_type := "Player"


var target: TargetableComponent


func find_nearest_target(from: Vector3):
	reset_target()
	var all_targets = get_tree().get_nodes_in_group("targets")
	var matching_targets = all_targets.filter(func (t: TargetableComponent): return t.target_type == target_type and t.is_enabled)
	var nearest_target: TargetableComponent
	var smallest_distance := INF
	for target in matching_targets:
		var distance = (target as Node3D).global_position.distance_squared_to(from) 
		if distance < smallest_distance:
			smallest_distance = distance
			nearest_target = target
	target = nearest_target
	if target:
		target.targetable_disabled.connect(_on_targetable_disabled)


func reset_target():
	if not target: return
	target.targetable_disabled.disconnect(_on_targetable_disabled)
	target = null


func _on_targetable_disabled():
	reset_target()
	emit_signal("target_lost")
