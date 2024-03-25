class_name HexCoordinate


static func get_neighbors(v: Vector2i) -> Array[Vector2i]:
	var x = v.x
	var y = v.y
	var is_odd_row = (y & 1) == 1
	return [
		Vector2i(x - 1, y),  # West
		Vector2i(x + 1, y),  # East
		Vector2i(x - (0 if is_odd_row else 1), y - 1),  # North-West
		Vector2i(x - (0 if is_odd_row else 1), y + 1),  # South-West
		Vector2i(x + (1 if is_odd_row else 0), y - 1),  # North-East
		Vector2i(x + (1 if is_odd_row else 0), y + 1)  # South-East
	]
