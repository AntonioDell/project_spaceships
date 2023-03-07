extends ParallaxBackground


@export var speed := 500.0



func _process(delta):
	offset.y += delta * speed
	if offset.y >= 3000: offset.y = 0
