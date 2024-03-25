extends Node

#@export var gcontrol : GameController
@export var ui: UserInterface
@export var level_loader: LevelLoader

@export var game_camera: GameCamera = null:
	get:
		if not game_camera:
			game_camera = _find_game_camera()
		return game_camera

@export var game_controller: GameController = null:
	get:
		if not game_controller:
			game_controller = _find_game_controller()
		return game_controller


func _find_game_camera() -> GameCamera:
	if level_loader.get_child_count() > 0:
		var gc = level_loader.get_child(0).find_child("GameCamera")
		if gc:
			return gc
	return null


func _find_game_controller() -> GameController:
	if level_loader.get_child_count() > 0:
		var gc = level_loader.get_child(0).find_child("GameController")
		if gc:
			return gc
	return null


func _process(_delta):
	if game_controller and game_controller.grid:
		game_controller.grid.human_count = ui.human_count
		ui.display_current_round = game_controller.grid.turn
		ui.current_mode = game_controller.grid.mode
		ui.control_game_loose = game_controller.human_player_loose
		ui.control_game_won = game_controller.human_player_win
		if game_controller.grid.current_player:
			ui.player_controls_disabled = (
				not game_controller.grid.current_player.is_human or game_controller.grid.merge
			)
		if not ui.end_turn.is_connected(_end_turn):
			ui.end_turn.connect(_end_turn)
		if not ui.set_mode.is_connected(_set_mode):
			ui.set_mode.connect(_set_mode)
		ui.show_merge_select = game_controller.grid.merge
		if not ui.merge_to.is_connected(_merge_to):
			ui.merge_to.connect(_merge_to)
	if game_camera:
		game_camera.zoom_level = ui.options_zoom


func _end_turn():
	game_controller.grid.current_player.end_turn()


func _set_mode(mode: Constants.Mode):
	game_controller.grid.mode = mode


func _merge_to(type: Constants.CharacterType):
	game_controller.grid._merge_to(type)
