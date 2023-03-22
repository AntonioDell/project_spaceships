extends Node


signal delay_passed


@export var min_delay: float
@export var max_delay: float

@onready var _timer := $Timer as Timer


func _ready():
	_timer.start(randf_range(min_delay, max_delay))


func _on_timer_timeout():
	emit_signal("delay_passed")
