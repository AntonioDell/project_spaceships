class_name PlayerControlComponent
extends Node

signal player_move(direction: Vector2)
signal player_shoots()
signal player_rolls()

@export var is_disabled := false

func _process(delta):
	if is_disabled: return
	
	var direction = Input.get_vector("move_left", "move_right", "move_down", "move_up")
	emit_signal("player_move", direction)
	if Input.is_action_pressed("shoot"):
		emit_signal("player_shoots")
	if Input.is_action_just_pressed("roll"):
		emit_signal("player_rolls")
