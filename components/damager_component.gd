class_name DamagerComponent
extends Area3D


signal damage_dealt(damage: Damage)


@export var damage: Damage
@export_enum("Player:2", "Enemy:4") var damage_target := 2:
	set(new_value):
		damage_target = new_value
		_set_physics_layers()
@export var is_disabled := false:
	set(new_value):
		is_disabled = new_value
		_enable_or_disable_area()


func _ready():
	_enable_or_disable_area()
	_set_physics_layers()


func _set_physics_layers():
	collision_layer = damage_target
	collision_mask = damage_target


func _on_area_entered(area):
	_deal_damage(area)


func _enable_or_disable_area():
	var should_check_for_areas = not monitoring and not is_disabled
	monitoring = not is_disabled
	monitorable = not is_disabled
	
	if should_check_for_areas:
		print("Check")
		await get_tree().physics_frame
		var areas = get_overlapping_areas()
		print("Areas", areas)
		for area in areas:
			_deal_damage(area)




func _deal_damage(area: Area3D):
	if not area is DamageReceiverComponent:
		return 
	emit_signal("damage_dealt", damage)
	
