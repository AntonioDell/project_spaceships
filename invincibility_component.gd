class_name InvincibilityComponent
extends Node


signal invincibility_started
signal invincibility_ended


# FIXME: Remove workaround when  https://github.com/godotengine/godot/issues/62916 is solved
@export var damage_receiver_paths: Array[NodePath]
@onready var damage_receivers: Array = damage_receiver_paths.map(get_node)
# FIXME: When https://github.com/godotengine/godot/issues/62916 is solved, this will work again
# @export var damage_receivers: Array[DamageReceiverComponent]
@export var duration := .5
@export var is_invincible := false:
	set(new_value):
		is_invincible = new_value
		if is_invincible:
			_start_invincibility()


func _start_invincibility():
	if not $Timer.is_stopped(): return
	$Timer.start(duration)
	for damage_receiver in damage_receivers:
		damage_receiver.set_deferred("monitoring", false)
		damage_receiver.set_deferred("monitorable", false)


func _on_timer_timeout():
	for damage_receiver in damage_receivers:
		damage_receiver.set_deferred("monitoring", true)
		damage_receiver.set_deferred("monitorable", true)
	is_invincible = false
