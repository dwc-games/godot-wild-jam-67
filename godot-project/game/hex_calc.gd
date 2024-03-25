class_name Coordinate  #Coordinate in Hex-grid (Odd-R)


static func get_min_distance_between(p1: Vector2i, p2: Vector2i) -> int:
	return max(abs(get_q(p1) - get_q(p2)), abs(get_r(p1) - get_r(p2)), abs(get_s(p1) - get_s(p2)))


static func get_q(v: Vector2i) -> int:
	return v.x - (v.y - (v.y & 1)) / 2


static func get_r(v: Vector2i) -> int:
	return v.y


static func get_s(v: Vector2i) -> int:
	return -get_q(v) - get_r(v)


#Odd-r to Axial
static func get_vector2i(q, r) -> Vector2i:
	var x = q + (r - (r & 1)) / 2
	var y = r
	return Vector2i(x, y)


static func get_neighbors(v: Vector2i) -> Array[Vector2i]:
	var q = get_q(v)
	var r = get_r(v)
	return [
		get_vector2i(q + 1, r),
		get_vector2i(q + 1, r - 1),
		get_vector2i(q, r - 1),
		get_vector2i(q - 1, r),
		get_vector2i(q - 1, r + 1),
		get_vector2i(q, r + 1)
	]

class TileDistance:
	var coordinate: Vector2i
	var distance: int

	func _init(coordinate: Vector2i, distance: int):
		self.coordinate = coordinate
		self.distance = distance

static func floodfill(start: Vector2i, maxrange: int, gamegrid: Array) -> Array[TileDistance]:
	var visited: Array[TileDistance] = []
	visited.append(TileDistance.new(start, 0))
	var fringes: Array[Vector2i] = []
	fringes.append(start)

	for k in range( maxrange ):  #Optimierungsmöglichkeit Fringes reduzieren
		var fringesbuffer = fringes.duplicate()
		for hex in fringesbuffer:
			var neighbors = get_neighbors(hex)
			for neighbor in neighbors:
				if neighbor in gamegrid and neighbor not in visited.map(func (t): return t.coordinate):
					visited.append(TileDistance.new(neighbor, k+1))
					fringes.append(neighbor)
	return visited
