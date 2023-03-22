extends Node3D


signal player_detected(player_position: Vector3)
signal player_lost(last_player_position: Vector3)


var _player: Node3D


func _physics_process(delta):
	if not _player: 
		return
	emit_signal("player_detected", _player.global_position)


func _on_area_3d_body_entered(body: Node3D):
	_player = body
	emit_signal("player_detected", _player.global_position)


func _on_area_3d_body_exited(body : Node3D):
	if not _player: return
	emit_signal("player_lost", _player.global_position)
	_player = null
