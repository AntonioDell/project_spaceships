extends CharacterBody3D


enum {IDLE, FIRE_ROCKETS, MOVE_LEFT, MOVE_RIGHT}


@onready var _gun_left := $GunLeft as Gun
@onready var _gun_right := $GunRight as Gun

var state := IDLE


func _physics_process(delta):
	match state:
		FIRE_ROCKETS:
			_fire_rockets()
		_:
			pass



func _on_player_detected(player_position: Vector3):
	state = FIRE_ROCKETS


var is_firing := false
func _fire_rockets():
	if is_firing: return
	is_firing = true
	# TODO: Use player position for firing at
	_gun_left.fire(Vector3.DOWN)
	_gun_right.fire(Vector3.DOWN)
	await get_tree().create_timer(2).timeout
	is_firing = false
	state = IDLE
