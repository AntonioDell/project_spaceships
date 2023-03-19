class_name EnemySpawner
extends Node


@export var possible_formations: Array[PackedScene]
@export var top_left_corner_reference: Node3D
@export var enemy_parent: Node3D
@export var size_1_enemies: Array[PackedScene]

func _ready():
	_spawn_next_formation()


func _spawn_next_formation():
	if not top_left_corner_reference or not enemy_parent: return
	
	if get_child_count() == 1:
		get_child(0).queue_free()
	var formation_scene := possible_formations.pick_random() as PackedScene
	var formation_node = formation_scene.instantiate()
	add_child(formation_node)
	
	var formation := (formation_node as FormationGrid).get_formation()
	for enemy_data in formation:
		var enemy_scene: PackedScene
		if enemy_data.required_size == Vector2i.ONE:
			enemy_scene = size_1_enemies.pick_random()
		else:
			push_error("No enemy satisfying required size %s exists" % enemy_data.required_size)
			continue
		var enemy = enemy_scene.instantiate() as Node3D
		enemy.position = top_left_corner_reference.position + (enemy_data.spawn_position / 64 * 3)
		if "move_direction" in enemy and "move_direction" in enemy_data:
			enemy.move_direction = Vector3(enemy_data.move_direction.x, enemy_data.move_direction.y, 0)
		enemy_parent.call_deferred("add_child", enemy)
