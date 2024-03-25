class_name GamePlayerHuman extends GamePlayer

signal turn_taken

var my_turn: bool = false

var _grid: GameGrid


func _ready():
	self.is_human = true


func take_turn(grid: GameGrid):
	_grid = grid
	if last_char and is_instance_valid(last_char):
		last_char.selected = true
	print("It's your turn!")
	my_turn = true
	_refresh_my_char_action_points(grid)
	await turn_taken
	my_turn = false


func _process(_delta):
	if my_turn:
		var my_chars = _grid.get_player_characters(self)
		if my_chars.size() < 1:
			end_turn()
			return
		if my_chars.all(func(c): return c.action_points < 1):
			end_turn()
			return
		if _grid.get_enemy_characters(self).size() < 1:
			end_turn()
			return


func _refresh_my_char_action_points(grid: GameGrid):
	if grid.get_player_characters(self).size() < 1:
		return
	for myChar in grid.get_player_characters(self):
		myChar.action_points = 1


var last_char: GameCharacter = null


func end_turn() -> void:
	last_char = null
	for myChar in _grid.get_player_characters(self):
		if myChar.selected:
			last_char = myChar
	my_turn = false
	turn_taken.emit()
