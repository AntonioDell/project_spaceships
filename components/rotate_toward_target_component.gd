class_name RotateTowardTargetComponent
extends Node


@export var nodes_to_rotate: Array[NodePath]
@export var angular_velocity := PI


var _target: Vector3

@onready var _nodes_to_rotate = nodes_to_rotate.map(get_node)


func start_rotation(target: Vector3):
	_target = target


func stop_rotation():
	_target = Vector3.ZERO


func _physics_process(delta: float):
	if _target == Vector3.ZERO: 
		return
	
	var target_position_2d = Vector2(_target.x, _target.y)
	for node in _nodes_to_rotate:
		var node_position_2d = Vector2(node.global_position.x, node.global_position.y)
		var direction = target_position_2d - node_position_2d
		
		var target_angle = atan2(direction.y, direction.x)
		var current_angle = node.global_rotation.z
		var necessary_rotation = wrapf(target_angle - current_angle, -PI, PI) + PI/2
		
		var previous_scale = (node as Node3D).scale
		node.global_rotation.z = lerp_angle(node.global_rotation.z, node.global_rotation.z + necessary_rotation, delta * angular_velocity)
		if previous_scale != node.scale:
			node.scale = previous_scale
