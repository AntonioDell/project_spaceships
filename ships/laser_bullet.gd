extends Area3D

var _motion := Vector3.ZERO

func _ready():
	($velocity_component as VelocityComponent).direction = Vector2(0, 1)
	await get_tree().physics_frame
	if not $VisibleOnScreenNotifier3D.is_on_screen():
		_on_screen_exited()

func _physics_process(delta):
	global_position += _motion * delta


func _on_velocity_changed(new_velocity, acceleration):
	_motion = Vector3(new_velocity.x, new_velocity.y, 0)


func _on_screen_exited():
	queue_free()
