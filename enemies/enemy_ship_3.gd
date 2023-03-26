extends Node3D


enum State {MOVE_INTO_SCREEN, FIND_TARGET, CHASE_TARGET, SHOW_DAMAGE_AREA, EXPLODE}


var _state = State.MOVE_INTO_SCREEN


func _process(_delta: float):
	match _state:
		State.MOVE_INTO_SCREEN: pass
		State.FIND_TARGET: pass
		State.CHASE_TARGET: pass
		State.SHOW_DAMAGE_AREA: pass
		State.EXPLODE: pass


