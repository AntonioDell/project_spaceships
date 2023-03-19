class_name DamageReceiverComponent
extends Area3D


signal damage_received(damage: Damage)


@export_enum("Player:4", "Enemy:2") var damage_source := 4:
	set(new_value):
		damage_source = new_value
		_set_physics_layers()


func _ready():
	_set_physics_layers()


func _on_area_entered(area):
	if area is DamagerComponent:
		_receive_damage(area.damage)


func _receive_damage(damage: Damage):
	emit_signal("damage_received", damage)


func _set_physics_layers():
	collision_layer = damage_source
	collision_mask = damage_source
