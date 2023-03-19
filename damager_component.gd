class_name DamagerComponent
extends Area3D


signal damage_dealt(damage: Damage)


@export var damage: Damage
@export_enum("Player:2", "Enemy:4") var damage_target := 2:
	set(new_value):
		damage_target = new_value
		_set_physics_layers()


func _set_physics_layers():
	collision_layer = damage_target
	collision_mask = damage_target


func _on_area_entered(area):
	emit_signal("damage_dealt", damage)
