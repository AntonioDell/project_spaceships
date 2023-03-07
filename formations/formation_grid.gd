class_name FormationGrid
extends TileMap


func get_formation() -> Array[Dictionary]:
	var size_coordinates := get_used_cells(0)
	
	var output: Array[Dictionary]= []
	for size_coordinate in size_coordinates:
		var size_tile_data := get_cell_tile_data(0, size_coordinate)
		var required_size := size_tile_data.get_custom_data_by_layer_id(0) as Vector2i
		var spawn_position = to_global(map_to_local(size_coordinate))
		var formation_entry := {"spawn_position": Vector3(spawn_position.x, -spawn_position.y, 0),"required_size": required_size}
		var direction_tile_data := get_cell_tile_data(1, size_coordinate)
		if direction_tile_data:
			formation_entry.move_direction = direction_tile_data.get_custom_data_by_layer_id(1) as Vector2 * Vector2.UP
		output.append(formation_entry)
		
	return output
