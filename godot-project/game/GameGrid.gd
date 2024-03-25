@tool
@icon("icons/grid.svg")

class_name GameGrid extends Node

@export var players: Array[GamePlayer] = []

@export var tiles: Array[GameTile] = []

var tiles_coords: Array:
	get:
		return tiles.map(func(tile): return tile.grid_position)

@export var characters: Array[GameCharacter] = []

var valid_characters: Array[GameCharacter]:
	get:
		return characters.filter(func(c): return is_instance_valid(c))

@export var pickups: Array[GamePickup] = []

var valid_pickups: Array[GamePickup]:
	get:
		return pickups.filter(func(p): return is_instance_valid(p))

var turn: int = 0:
	set(value):
		turn = value
		_deselect_all_characters()

var current_player: GamePlayer = null

var mode: Constants.Mode = Constants.Mode.MOVE

var player_character_selection: GameCharacter = null:
	get:
		for character in valid_characters:
			if character.selected and character.player_id == current_player.player_id:
				return character
		return null


func get_player_characters(player: GamePlayer) -> Array[GameCharacter]:
	return valid_characters.filter(func(character): return character.player_id == player.player_id)


func get_enemy_characters(player: GamePlayer) -> Array[GameCharacter]:
	return valid_characters.filter(func(character): return character.player_id != player.player_id)


func _ready():
	players.clear()
	_loadObjectsFromLevel()
	_connect_signals()


func _process(_delta):
	if Engine.is_editor_hint():
		_loadObjectsFromLevel()
	else:
		if players.size() == 3:
			_update_based_on_state()


var human: Resource = preload("res://game/player_human.tscn")
var bot: Resource = preload("res://game/player_bot.tscn")

var human_count: int = -1:
	set(value):
		human_count = value
		_set_players()


func _set_players() -> bool:
	if human_count < 0:
		return false
	if players.size() > 2:
		return false
	print("Setting human players to ", human_count)
	players.clear()
	for i in range(3):
		if i < human_count:
			var p = human.instantiate()
			p.name = "p%d_" % i + p.name
			p.player_id = i
			print("adding player " + p.name)
			$Players.add_child(p)
			players.append(p)
		else:
			var p = bot.instantiate()
			p.name = "p%d_" % i + p.name
			p.player_id = i
			print("adding player " + p.name)
			$Players.add_child(p)
			players.append(p)
	return true


func _loadObjectsFromLevel():
	var foundTiles = find_children("*", "GameTile")
	tiles.clear()
	for tile in foundTiles:
		tiles.append(tile)
	_report_duplicate_tile_positions()
	var foundCharacters = find_children("*", "GameCharacter")
	characters.clear()
	for character in foundCharacters:
		characters.append(character)
	var foundPickups = find_children("*", "GamePickup")
	pickups.clear()
	for pickup in foundPickups:
		pickups.append(pickup)
	_report_duplicate_pickup_positions()


func _report_duplicate_tile_positions():
	var tile_positions = []
	for tile in tiles:
		if tile.grid_position in tile_positions:
			print("Duplicate tile position: ", tile.grid_position)
		tile_positions.append(tile.grid_position)


func _report_duplicate_pickup_positions():
	var pickup_positions = []
	for pickup in pickups:
		if pickup.current_tile.grid_position in pickup_positions:
			print("Duplicate pickup position: ", pickup.current_tile.grid_position)
		pickup_positions.append(pickup.current_tile.grid_position)


func _connect_signals():
	for character in characters:
		character.kill_me.connect(_kill_character.bind(character))


func _update_based_on_state():
	current_player = players[turn % players.size()]
	_update_highlight_moves()
	_update_hightlight_attacks()
	_update_hightlight_merge()
	_update_show_status()
	_only_select_player_characters()
	_only_select_one_player_character()
	_update_pickups()
	_update_merge()
	_spawn_random_pickup_if_map_empty()


var pickup_spawn: Resource = preload("res://game/gamePickup.tscn")

var last_pickup_spawn_turn: int = 5


func _spawn_random_pickup_if_map_empty():
	if valid_pickups.size() == 0 and turn % 4 == 0 and turn > last_pickup_spawn_turn:
		last_pickup_spawn_turn = turn
		var pick: GamePickup = pickup_spawn.instantiate()
		var possible_spawns = tiles.filter(func(t): return get_character_on(t) == null)
		pick.current_tile = possible_spawns[randi() % possible_spawns.size()]
		pick.set_to_tile()
		pickups.append(pick)
		$Tiles.add_child(pick)


var to_merge: Array[GameCharacter] = []

var merge: bool = false:
	set(value):
		merge = value

var chars_to_merge: Array[GameCharacter] = []


func _update_merge():
	if not merge:
		var chars = get_player_characters(current_player)
		var merge_chars = chars.filter(
			func(character): return chars.any(
				func(x): return x != character and x.current_tile == character.current_tile
			)
		)
		if merge_chars.size() > 1:
			merge = true
			chars_to_merge = merge_chars


func _merge_to(character_type: Constants.CharacterType):
	if merge:
		if chars_to_merge[0].action_points == 0:
			chars_to_merge.reverse()
		chars_to_merge[0].character_type = character_type
		_kill_character(chars_to_merge[1])
		merge = false


func _update_highlight_moves():
	for tile in tiles:
		tile.highlighted = false
		if tile.got_selected.is_connected(move_character_to_tile):
			tile.got_selected.disconnect(move_character_to_tile)
	if mode != Constants.Mode.MERGE:
		# if true:
		var currentCharacter = player_character_selection
		if currentCharacter and currentCharacter.action_points > 0:
			var valid_moves = get_valid_movements(currentCharacter)
			for tile in tiles:
				if valid_moves.has(tile) and not get_character_on(tile):
					tile.highlighted = true
					tile.got_selected.connect(move_character_to_tile.bind(currentCharacter, tile))


func get_character_on(tile: GameTile) -> GameCharacter:
	for character in characters:
		if character.current_tile == tile:
			return character
	return null


func get_pickup_on(tile: GameTile) -> GamePickup:
	for pickup in valid_pickups:
		if pickup.current_tile == tile:
			return pickup
	return null


var previous_selected: GameCharacter = null


func _only_select_player_characters():
	var enemies = get_enemy_characters(current_player)
	enemies.map(func(enemy): enemy.selected = false)


func _only_select_one_player_character():
	# if mode == Constants.Mode.MERGE:
	# 	return
	var selected = get_player_characters(current_player).filter(
		func(character): return character.selected
	)
	if selected.size() > 1:
		previous_selected.selected = false
	if selected.size() == 1:
		previous_selected = selected[0]


func move_character_to_tile(character: GameCharacter, tile: GameTile):
	character.move_to_tile(tile)


func _update_hightlight_attacks():
	var enemies = get_enemy_characters(current_player)
	for enemy in enemies:
		enemy.highlighted = false
		if enemy.got_selected.is_connected(_attack_character):
			enemy.got_selected.disconnect(_attack_character)
	if mode != Constants.Mode.MERGE:
		# if true:
		var currentCharacter = player_character_selection
		if currentCharacter and currentCharacter.action_points > 0:
			var attackableCharacters = _get_valid_attacks(currentCharacter)
			for target in attackableCharacters:
				target.highlighted = true
				target.got_selected.connect(_attack_character.bind(currentCharacter, target))


func _attack_character(character: GameCharacter, target: GameCharacter):
	character.attack(target)


func _update_hightlight_merge():
	var chars = get_player_characters(current_player)
	for c in chars:
		c.highlighted = false
		if c.got_selected.is_connected(_merge_character):
			c.got_selected.disconnect(_merge_character)
	if mode == Constants.Mode.MERGE:
		# if true:
		var currentCharacter = player_character_selection
		if currentCharacter and currentCharacter.action_points > 0:
			var mergeableCharacters = _get_valid_merges(currentCharacter)
			mergeablechars = mergeableCharacters
			for target in mergeableCharacters:
				target.highlighted = true
				target.got_selected.connect(_merge_character.bind(currentCharacter, target))


@export var mergeablechars: Array[GameCharacter] = []


func _merge_character(character: GameCharacter, target: GameCharacter):
	character.move_to_tile(target.current_tile)


func get_valid_movements(character: GameCharacter):
	var neighbors = get_tiles_up_to_distance(character.current_tile, 1)
	return neighbors.filter(func(tile): return get_character_on(tile) == null)


func get_tiles_up_to_distance(tile: GameTile, max_range: int):
	var neighbor_tiles: Array[GameTile] = []
	var coordinates: Array = Coordinate.floodfill(tile.grid_position, max_range, tiles_coords).map(
		func(d): return d.coordinate
	)
	for t in tiles:
		if coordinates.has(t.grid_position):
			neighbor_tiles.append(t)
	return neighbor_tiles


func get_closest_pickup_tiles(character: GameCharacter, max_range: int = 10):
	var closest_pickups: Array = []
	for d in range(1, max_range):
		var target_tiles = get_tiles_up_to_distance(character.current_tile, d)
		var close_pickups = valid_pickups.filter(
			func(pickup): return target_tiles.has(pickup.current_tile)
		)
		if close_pickups.size() > 0:
			closest_pickups = close_pickups.map(
				func(pickup): return tiles[tiles.find(pickup.current_tile)]
			)
			break
	return closest_pickups


func get_closest_enemy_tiles(character: GameCharacter, max_range: int = 10):
	var closest_enemies: Array = []
	for d in range(1, max_range):
		var target_tiles = get_tiles_up_to_distance(character.current_tile, d)
		var close_enemies = get_enemy_characters(current_player).filter(
			func(enemy): return target_tiles.has(enemy.current_tile)
		)
		if close_enemies.size() > 0:
			closest_enemies = close_enemies.map(
				func(enemy): return tiles[tiles.find(enemy.current_tile)]
			)
			break
	return closest_enemies


func get_closest_enemy_type_tiles(
	character: GameCharacter, type: Constants.CharacterType, max_range: int = 10
):
	var closest_enemies: Array = []
	for d in range(1, max_range):
		var target_tiles = get_tiles_up_to_distance(character.current_tile, d)
		var close_enemies = (
			get_enemy_characters(current_player)
			. filter(func(enemy): return target_tiles.has(enemy.current_tile))
			. filter(func(enemy): return enemy.character_type == type)
		)
		if close_enemies.size() > 0:
			closest_enemies = close_enemies.map(
				func(enemy): return tiles[tiles.find(enemy.current_tile)]
			)
			break
	return closest_enemies


func get_closest(character: GameCharacter, targets: Array, max_range: int = 10) -> Array:
	for d in range(1, max_range):
		var target_tiles = get_tiles_up_to_distance(character.current_tile, d)
		var close_targets = targets.filter(
			func(target): return target_tiles.has(target.current_tile)
		)
		if close_targets.size() > 0:
			return [close_targets[0], d]
	return []


func get_closest_friendly_tiles(character: GameCharacter, max_range: int = 10):
	var closest_friends: Array = []
	for d in range(1, max_range):
		var target_tiles = get_tiles_up_to_distance(character.current_tile, d)
		var close_friends = get_player_characters(current_player).filter(
			func(friend): return target_tiles.has(friend.current_tile)
		)
		if close_friends.size() > 0:
			closest_friends = close_friends.map(
				func(friend): return tiles[tiles.find(friend.current_tile)]
			)
			break
	return closest_friends


const MAX_PATH_LENGTH = 20


func get_path_to_tile(character: GameCharacter, target_tile: GameTile):
	var path: Array[GameTile] = []
	var current_tile = character.current_tile
	var distances = Coordinate.floodfill(target_tile.grid_position, MAX_PATH_LENGTH, tiles_coords)
	var dict = {}
	distances.map(func(d): dict[d.coordinate] = d.distance)
	while current_tile != target_tile:
		var neighbors = get_tiles_up_to_distance(current_tile, 1).filter(
			func(t): return not get_character_on(t)
		)
		if neighbors.size() == 0:
			return path
		var possible_next_tiles = neighbors.filter(
			func(tile): return dict[tile.grid_position] < dict[current_tile.grid_position]
		)
		if possible_next_tiles.size() == 0:
			return path
		var next_tile = possible_next_tiles[0]
		path.append(next_tile)
		current_tile = next_tile
	return path


func _get_valid_attacks(character: GameCharacter) -> Array[GameCharacter]:
	var attackableCharacters: Array[GameCharacter] = []
	var enemies = get_enemy_characters(current_player)
	#var valid_moves = get_valid_movements(character)
	var valid_moves = get_tiles_up_to_distance(character.current_tile, 1)
	for enemy in enemies:
		if enemy.current_tile in valid_moves:
			attackableCharacters.append(enemy)
	return attackableCharacters


func _get_valid_merges(character: GameCharacter) -> Array[GameCharacter]:
	var mergeableCharacters: Array[GameCharacter] = []
	var my_chars = get_player_characters(current_player)
	#var valid_moves = get_valid_movements(character)
	var valid_moves = get_tiles_up_to_distance(character.current_tile, 1)
	valid_moves.erase(character.current_tile)
	for c in my_chars:
		if c.current_tile in valid_moves:
			mergeableCharacters.append(c)
	return mergeableCharacters


func _update_show_status():
	for character in characters:
		if character.player_id == current_player.player_id:
			character.show_status = true
		else:
			character.show_status = false


func _deselect_all_characters():
	for character in characters:
		character.selected = false


func _kill_character(character: GameCharacter):
	characters.erase(character)
	print("Character killed ", character)
	character.queue_free()


func _add_character(character: GameCharacter):
	print("Character added ", character)
	character.kill_me.connect(_kill_character.bind(character))
	characters.append(character)


func _update_pickups():
	for character in characters:
		var picks = valid_pickups.filter(
			func(pickup): return pickup.current_tile == character.current_tile
		)
		if picks.size() > 0:
			_use_pickup(picks[0], character)


func _use_pickup(pickup: GamePickup, character: GameCharacter):
	match pickup.pickup_type:
		Constants.PickupType.DUPLICATE:
			_kill_pickup(pickup)
			_duplicate_character(character)
			character.consume_pickup_sound()


func _kill_pickup(pickup: GamePickup):
	pickups.erase(pickup)
	print("Pickup killed ", pickup)
	pickup.queue_free()


func _duplicate_character(character: GameCharacter):
	var newCharacter = character.duplicate(DUPLICATE_USE_INSTANTIATION)
	var spawnTile = (
		get_valid_movements(character)
		. filter(func(tile): return not get_character_on(tile) and not get_pickup_on(tile))[0]
	)
	newCharacter.current_tile = spawnTile
	newCharacter.action_points = 0
	newCharacter.selected = false
	newCharacter.show_status = false
	newCharacter.player_id = character.player_id
	newCharacter._placeOnTile()
	_add_character(newCharacter)
	$Characters.add_child(newCharacter)
