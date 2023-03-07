extends Node


@export var origin_point: Node2D
@export var target_point: VisibleOnScreenNotifier2D
@export var speed := .5

@onready var _direction := (origin_point.global_position - target_point.global_position).normalized() 
@onready var _parent = get_parent()

func _ready():
	if not _parent is Node2D:
		push_warning("%s cannot scroll nodes of type %s" % [name, _parent.get_class()]) 
		return
	target_point.screen_entered.connect(_duplicate_parent)
	target_point.screen_exited.connect(_destroy_parent)


func _process(delta):
	if not _parent is Node2D: return
	var scroll_amount = Vector2(_direction.x, _direction.y) * delta * speed
	_parent.position += scroll_amount


func _duplicate_parent():
	var new_scroller := PreloadedResources.scrolling_background_scene.instantiate()
	_parent.add_sibling(new_scroller)
	new_scroller.global_position = target_point.global_position


func _destroy_parent():
	_parent.queue_free()
