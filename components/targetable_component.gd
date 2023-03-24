class_name TargetableComponent
extends Node3D


signal targetable_disabled


@export_enum("Player", "Enemy", "All") var target_type := "Player"
@export var is_enabled := true:
	set(new_value):
		is_enabled = new_value
		if not is_enabled:
			emit_signal("targetable_disabled")


@onready var _visible_on_screen_notifier := $VisibleOnScreenNotifier3D as VisibleOnScreenNotifier3D


func _ready():
	is_enabled = _visible_on_screen_notifier.is_on_screen()


func _on_visible_on_screen_notifier_3d_screen_exited():
	is_enabled = false


func _on_visible_on_screen_notifier_3d_screen_entered():
	is_enabled = true
