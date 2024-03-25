class_name GamePlayerBot extends GamePlayer

signal turn_taken

var my_turn: bool = false

var _grid: GameGrid

@export var flee_distance = 3
@export var fight_distance = 3

var _turns_without_decision: int = 0


func take_turn(grid: GameGrid):
	_grid = grid
	print("Bot is taking turn")
	my_turn = true
	_refresh_my_char_action_points(_grid)
	_turns_without_decision = 0
	# do stuff in process
	await turn_taken
	my_turn = false


func _process(_delta: float):
	if waiting_to_merge:
		if _grid.merge:
			choose_merge_type.emit()
		return
	if my_turn:
		_end_if_no_characters(_grid)
		_end_if_no_action_points(_grid)
		_end_if_undecided_for(10)
	if my_turn:
		var characters = _grid.get_player_characters(self).filter(
			func(c): return c.action_points > 0
		)
		var selected_character = characters[randi() % characters.size()]
		if _decide_and_do_an_action(_grid, selected_character):
			_turns_without_decision = 0
		else:
			_turns_without_decision += 1

func _end_if_undecided_for(too_many_turns: int):
	if _turns_without_decision > too_many_turns:
		_end_turn()

func _decide_and_do_an_action(grid: GameGrid, character: GameCharacter) -> bool:
	var victims = grid.get_enemy_characters(self).filter(
		func(enemy): return enemy.character_type == _get_victim_type(character.character_type)
	)
	var enemys = grid.get_enemy_characters(self).filter(
		func(enemy): return enemy.character_type == _get_enemy_type(character.character_type)
	)
	var characters = grid.get_player_characters(self)
	var pickups = grid.pickups

	var closest_victim_array = grid.get_closest(character, victims)
	var closest_enemy_array = grid.get_closest(character, enemys)
	var closest_character_array = grid.get_closest(
		character, characters.filter(func(picked_character): return character != picked_character)
	)
	var closest_pickup_array = grid.get_closest(character, pickups)

	if victims.size() == 0:  # Es gibt keine Victims
		if characters.size() > 1:
			print("Ich, ", character, " kann mergen und es gibt keine Opfer -> Merge")
			if enemys.size() > 0:
				if _merge(grid, character, _get_enemy_type(enemys[0].character_type)):
					return true
				if _move_to_merge(grid, character):
					return true
			else:  # Keine Victims und keine Enemys: nur "gleiche" Gegner
				if _merge(grid, character, _get_enemy_type(character.character_type)):
					return true
				if _move_to_merge(grid, character):
					return true
			if _move_to_closest_pickup(grid, character):
				return true
			return _random_move(grid, character)
		else:
			print("Ich, ", character, " kann nicht mergen und es gibt keine Opfer -> Powerup")
			if _move_to_closest_pickup(grid, character):
				return true
			return _random_move(grid, character)
	else:  #Es gibt Victims
		if (
			pickups.size() > 0
			and victims.size() > 0
			and closest_victim_array.size() > 0
			and closest_pickup_array.size() > 0
			and closest_pickup_array[1] < closest_victim_array[1]
		):
			print("Powerup ist n�her als Opfer -> Powerup")
			if _move_to_closest_pickup(grid, character):
				return true
			return _random_move(grid, character)
		else:
			print("Opfer ist n�her als Pickup -> Kill")
			if _attack_closest_victim(grid, character):
				return true
			if _move_to_closest_victim(grid, character):
				return true
			if _move_to_closest_pickup(grid, character):
				return true
			return _random_move(grid, character)
	return false

	#if _move_to_closest_pickup(grid, character):
	#	return
	#if _merge(grid, character, randi() % 3):
	#	return
	#if _move_to_merge(grid, character):
	#	return
	#if _attack_closest_victim(grid, character):
	#	return
	#if _move_to_closest_victim(grid, character):
	#	return
	#_random_move(grid, character)


func _refresh_my_char_action_points(grid: GameGrid):
	if grid.get_player_characters(self).size() == 0:
		return
	for myChar in grid.get_player_characters(self):
		myChar.action_points = 1


func _random_move(grid: GameGrid, character: GameCharacter) -> bool:
	var moves = grid.get_valid_movements(character)
	if moves.size() > 0:
		var move = moves[randi() % moves.size()]
		grid.move_character_to_tile(character, move)
		return true
	return false


func _move_to_closest_pickup(grid: GameGrid, character: GameCharacter) -> bool:
	var pickups = grid.get_closest_pickup_tiles(character)
	if pickups.size() > 0:
		var pickup = pickups[randi() % pickups.size()]
		var path = grid.get_path_to_tile(character, pickup)
		if path.size() > 0:
			grid.move_character_to_tile(character, path[0])
			return true
	return false


## Flee from Enemy


func _get_victim_type(my_type: Constants.CharacterType) -> Constants.CharacterType:
	match my_type:
		Constants.CharacterType.ROCK:
			return Constants.CharacterType.SCISSORS
		Constants.CharacterType.SCISSORS:
			return Constants.CharacterType.PAPER
		Constants.CharacterType.PAPER:
			return Constants.CharacterType.ROCK
		_:
			return my_type


func _get_enemy_type(my_type: Constants.CharacterType) -> Constants.CharacterType:
	match my_type:
		Constants.CharacterType.ROCK:
			return Constants.CharacterType.PAPER
		Constants.CharacterType.SCISSORS:
			return Constants.CharacterType.ROCK
		Constants.CharacterType.PAPER:
			return Constants.CharacterType.SCISSORS
		_:
			return my_type


func _move_to_closest_victim(grid: GameGrid, character: GameCharacter) -> bool:
	var enemy_tiles = []
	match character.character_type:
		Constants.CharacterType.ROCK:
			enemy_tiles = grid.get_closest_enemy_type_tiles(
				character, Constants.CharacterType.SCISSORS
			)
		Constants.CharacterType.SCISSORS:
			enemy_tiles = grid.get_closest_enemy_type_tiles(
				character, Constants.CharacterType.PAPER
			)
		Constants.CharacterType.PAPER:
			enemy_tiles = grid.get_closest_enemy_type_tiles(character, Constants.CharacterType.ROCK)
	if enemy_tiles.size() < 1:
		return false
	else:
		var enemy_tile = enemy_tiles[randi() % enemy_tiles.size()]
		var path = grid.get_path_to_tile(character, enemy_tile)
		if path.size() > 0:
			grid.move_character_to_tile(character, path[0])
			return true
	return false


func _attack_closest_victim(grid: GameGrid, character: GameCharacter) -> bool:
	var enemy_tiles = []
	match character.character_type:
		Constants.CharacterType.ROCK:
			enemy_tiles = grid.get_closest_enemy_type_tiles(
				character, Constants.CharacterType.SCISSORS
			)
		Constants.CharacterType.SCISSORS:
			enemy_tiles = grid.get_closest_enemy_type_tiles(
				character, Constants.CharacterType.PAPER
			)
		Constants.CharacterType.PAPER:
			enemy_tiles = grid.get_closest_enemy_type_tiles(character, Constants.CharacterType.ROCK)
	if enemy_tiles.size() < 1:
		return false
	else:
		var enemy_tile = enemy_tiles[randi() % enemy_tiles.size()]
		var path = grid.get_path_to_tile(character, enemy_tile)
		if (
			path.size() < 1
			and grid._get_valid_attacks(character).size() > 0
			and (
				enemy_tile
				in grid._get_valid_attacks(character).map(
					func(valid_char): return valid_char.current_tile
				)
			)
		):
			character.attack(grid.get_character_on(enemy_tile))
			return true
	return false


func _move_to_merge(grid: GameGrid, character: GameCharacter) -> bool:
	var friends = grid.get_closest_friendly_tiles(character)
	if friends.size() > 0:
		var friend = friends[randi() % friends.size()]
		var path = grid.get_path_to_tile(character, friend)
		if path.size() > 0:
			character.move_to_tile(path[0])
			return true
	return false


signal choose_merge_type
var waiting_to_merge: bool = false


func _merge(grid: GameGrid, character: GameCharacter, type: Constants.CharacterType) -> bool:
	var valid_merge_characters = grid._get_valid_merges(character)
	if valid_merge_characters.size() > 0:
		character.move_to_tile(valid_merge_characters[0].current_tile)
		_choose_merge_type(grid, type)
		waiting_to_merge = true
		return true
	return false


func _choose_merge_type(grid: GameGrid, type: Constants.CharacterType):
	await choose_merge_type
	grid._merge_to(type)
	waiting_to_merge = false


func _end_if_no_characters(grid: GameGrid):
	if grid.get_player_characters(self).size() == 0:
		_end_turn()


func _end_if_no_action_points(grid: GameGrid):
	if grid.get_player_characters(self).all(func(c): return c.action_points == 0):
		_end_turn()


func _end_turn():
	my_turn = false
	turn_taken.emit()
