@tool
class_name GameController extends Node

@export var grid: GameGrid = null

var run_game: bool = false
var human_player_win: bool = false
var human_player_loose: bool = false

func _ready():
	start_game()
	next_turn_timer.one_shot = true
	next_turn_timer.timeout.connect(_next_turn.bind())
	add_child(next_turn_timer)
	next_turn_timer.start(.5)


func start_game():
	_loadObjectsFromLevel()
	run_game = true
	print("Game started")


var next_turn_timer = Timer.new()


func _next_turn():
	if run_game:
		print("Turn " + str(grid.turn) + " - Player " + str(grid.current_player.player_id))
		await grid.current_player.take_turn(grid)
		print("Turn " + str(grid.turn) + " ended")
		if _check_winner():
			run_game = false
			print("Player " + str(grid.current_player.player_id) + " wins!")
			if grid.current_player.is_human:
				human_player_win = true
			else:
				human_player_loose = true
			return
		grid.turn += 1
		next_turn_timer.start(.5)


func _check_winner():
	if grid.get_enemy_characters(grid.current_player).size() > 0:
		return false
	else:
		return true


func _process(_delta):
	if Engine.is_editor_hint():
		_loadObjectsFromLevel()


func _loadObjectsFromLevel():
	grid = find_child("GameGrid")
	if not grid:
		print("No GameGrid found")
