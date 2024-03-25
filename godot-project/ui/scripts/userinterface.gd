class_name UserInterface
extends CanvasLayer

#UI Control
@export var control_paused: bool = false
@export var control_level: Constants.Level
@export var player_controls_disabled: bool = false
signal end_turn
signal set_mode(mode: Constants.Mode)
@export var current_mode: Constants.Mode = Constants.Mode.MOVE
signal merge_to(character_type: Constants.CharacterType)
@export var show_merge_select: bool = false
var control_game_won: bool 
@export var control_game_loose: bool
#UI Display
@export var display_current_round: int = 0
@export var display_current_turn: String

#Options
@export var options_volume_music: int = 75
@export var options_volume_general: int = 75
@export var options_playername: String = "Player"
@export var options_zoom: int = 1

const THEME = preload("res://ui/ressources/theme.tres")
const button_normal: Texture2D = preload("res://ui/ressources/images/button_normal_selected.png")
const button_hover: Texture2D = preload("res://ui/ressources/images/button_hover_selected.png")

const button_win = preload("res://ui/ressources/images/winscreen.png")
const button_loose = preload("res://ui/ressources/images/loosescreen.png")

#Overrides for Mode selection:
var button_mode_selected_normal: StyleBoxTexture = StyleBoxTexture.new()
var button_mode_selected_hover: StyleBoxTexture = StyleBoxTexture.new()

var ui_complete: Array[Node] = []
var ui_options_volume_general: Node
var ui_options_volume_music: Node
var ui_submenu_levels_grid: Node
var ui_fullscreen: Node
var ui_ingame_round_count: Node
var ui_overlay_button_round: Node
var ui_overlay_button_mode: Array[Node] = []
var ui_startup: Array[Node] = []
var ui_submenu_levels : Array[Node] = []
var ui_ingame_overlay: Array[Node] = []
var ui_merge_selection: Array[Node] = []
var ui_ingame_menu: Array[Node] = []
var ui_options: Array[Node] = []
var ui_ingame_end: Array[Node] = []
var ui_ingame_end_display: Button
var ui_ingame_overlay_button_attack: Node
var ui_ingame_overlay_button_merge: Node
var ui_ingame_overlay_button_move: Node
var ui_tutorial: Array[Node] =[]
var ui_final: Array[Node] = []
var ui_theme: Array[Node] = []
var ui_zoom_slider: Node
var ui_bot_count: Label
var ui_human_count: Label

func _load_local_ui_resources():
	ui_complete = get_tree().get_nodes_in_group("ui_complete")
	ui_options_volume_general = get_tree().get_first_node_in_group("ui_options_volume_general")
	ui_options_volume_music = get_tree().get_first_node_in_group("ui_options_volume_music")
	ui_submenu_levels_grid = get_tree().get_first_node_in_group("ui_submenu_levels_grid")
	ui_fullscreen = get_tree().get_first_node_in_group("ui_fullscreen")
	ui_ingame_round_count = get_tree().get_first_node_in_group("ui_ingame_round_count")
	ui_overlay_button_round = get_tree().get_first_node_in_group("ui_overlay_button_round")
	ui_overlay_button_mode = get_tree().get_nodes_in_group("ui_overlay_button_mode")
	ui_startup = get_tree().get_nodes_in_group("ui_startup")
	ui_submenu_levels = get_tree().get_nodes_in_group("ui_submenu_levels")
	ui_ingame_overlay = get_tree().get_nodes_in_group("ui_ingame_overlay")
	ui_merge_selection = get_tree().get_nodes_in_group("ui_merge_selection")
	ui_ingame_menu = get_tree().get_nodes_in_group("ui_ingame_menu")
	ui_options = get_tree().get_nodes_in_group("ui_options")
	ui_ingame_end = get_tree().get_nodes_in_group("ui_ingame_end")
	ui_ingame_end_display = get_tree().get_first_node_in_group("ui_ingame_end_display")
	ui_ingame_overlay_button_attack = get_tree().get_first_node_in_group("ui_ingame_overlay_button_attack")
	ui_ingame_overlay_button_move = get_tree().get_first_node_in_group("ui_ingame_overlay_button_move")
	ui_ingame_overlay_button_merge = get_tree().get_first_node_in_group("ui_ingame_overlay_button_merge")
	ui_tutorial = get_tree().get_nodes_in_group("ui_tutorial")
	ui_final = get_tree().get_nodes_in_group("ui_final")
	ui_theme = get_tree().get_nodes_in_group("ui_godot")
	ui_zoom_slider = get_tree().get_first_node_in_group("ui_zoom_slider")
	ui_bot_count = get_tree().get_first_node_in_group("ui_bot_count")
	ui_human_count = get_tree().get_first_node_in_group("ui_human_count")

func _ready():
	continue_timer.one_shot = true
	continue_timer.timeout.connect(_reset_continue.bind())
	add_child(continue_timer)
	_load_local_ui_resources()
	_generate_level_ui()
	_load_local_ui_resources()
	for ui_node in ui_complete:
		ui_node.set_theme(THEME)

	_set_visibility_with_tween(ui_complete, false)
	_set_visibility_with_tween(ui_theme, true)
	await get_tree().create_timer(5).timeout
	_set_visibility_with_tween(ui_theme, false)
	
	if %LevelLoader.cur_level == Constants.Level.STARTUP:
		_set_visibility_with_tween(ui_startup)

	ui_options_volume_general.set_value(options_volume_general)
	ui_options_volume_music.set_value(options_volume_music)
	
	button_mode_selected_normal.set_texture(button_normal)
	#button_mode_selected_normal.set_texture_margin_all(18.0)
	button_mode_selected_hover.set_texture(button_hover)
	#button_mode_selected_hover.set_texture_margin_all(18.0)

func _level_to_name(level : Constants.Level) -> String:
	match level:
		Constants.Level.SKIN:
			return "Skin Surface Skirmish"
		Constants.Level.BLOOD:
			return "Bloodstream Battle"
		Constants.Level.BRAIN:
			return "Blood-Brain Barrier Brawl"
		Constants.Level.NEURAL:
			return "Neural Network Showdown"
		_:
			return "Unknown"

func _generate_level_ui():
	for x in Constants.Level:
		if (
			not Constants.Level[x] == Constants.Level.TEST
			and not Constants.Level[x] == Constants.Level.STARTUP
		):
			var lvl_button = Button.new()
			ui_submenu_levels_grid.add_child(lvl_button)
			lvl_button.add_to_group("ui_complete")
			lvl_button.add_to_group("ui_submenu_levels")
			lvl_button.set_name(x)
			lvl_button.text = _level_to_name(Constants.Level[x])
			lvl_button.size_flags_stretch_ratio = 1.0
			lvl_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			lvl_button.size_flags_vertical = Control.SIZE_EXPAND_FILL
			lvl_button.custom_minimum_size = Vector2(400, 50)
			lvl_button.pressed.connect(self._button_pressed.bind(Constants.Level[x]))


func _load_level(level: Constants.Level):
	%LevelLoader.load_level(level)
	control_paused = false


func _button_pressed(level):
	_load_level(level)
	_set_visibility_with_tween(ui_ingame_end, false)
	_set_visibility_with_tween(ui_startup, false)
	_set_visibility_with_tween(ui_submenu_levels, false)
	_set_visibility_with_tween(ui_ingame_overlay, true)


func _process(_delta):
	ui_fullscreen.set_mouse_filter(0 if control_paused else 2)

	if %LevelLoader.cur_level != Constants.Level.STARTUP:
		ui_ingame_round_count.set_text(str(display_current_round))

		_set_visibility_with_tween(ui_merge_selection, show_merge_select)

	if player_controls_disabled == true:
		ui_overlay_button_mode.map(func(n): n.set_disabled(true))
		ui_overlay_button_round.set_disabled(true)
		ui_overlay_button_round.set_text(
			"Choose a new Type" if show_merge_select else "Wait for your Turn"
		)
	else:
		ui_overlay_button_mode.map(func(n): n.set_disabled(false))
		ui_overlay_button_round.set_disabled(false)
		ui_overlay_button_round.set_text("End Turn")

	if control_game_won == true or control_game_loose == true:
		control_paused = true
		#_set_visibility_with_tween(ui_ingame_overlay, false)
		ui_ingame_end_display.icon = button_win if control_game_won else button_loose
		_set_visibility_with_tween(ui_ingame_end, true)

	if current_mode == Constants.Mode.MOVE:
		ui_ingame_overlay_button_move["theme_override_styles/normal"] = button_mode_selected_hover
		ui_ingame_overlay_button_move["theme_override_styles/hover"] = button_mode_selected_hover
	else:
		ui_ingame_overlay_button_move["theme_override_styles/normal"] = null
	if current_mode == Constants.Mode.MERGE:
		ui_ingame_overlay_button_merge["theme_override_styles/hover"] = button_mode_selected_hover
		ui_ingame_overlay_button_merge["theme_override_styles/normal"] = button_mode_selected_hover
	else:
		ui_ingame_overlay_button_merge["theme_override_styles/normal"] = null
	#if current_mode == Constants.Mode.ATTACK:
		#ui_ingame_overlay_button_attack["theme_override_styles/hover"] = button_mode_selected_hover
		#ui_ingame_overlay_button_attack["theme_override_styles/normal"] = button_mode_selected_normal
	#else:
		#ui_ingame_overlay_button_attack["theme_override_styles/normal"] = null		

#Overlay Ingame
func _on_button_menu_pressed():
	_set_visibility_with_tween(ui_ingame_overlay, false)
	_set_visibility_with_tween(ui_ingame_menu, true)
	control_paused = true


func _on_button_overlay_round_done_pressed():
	end_turn.emit()


func _on_button_control_move_pressed():
	set_mode.emit(Constants.Mode.MOVE)


func _on_button_control_attack_pressed():
	set_mode.emit(Constants.Mode.ATTACK)


func _on_button_3_control_merge_pressed():
	set_mode.emit(Constants.Mode.MERGE)


func _on_h_slider_value_changed(value):
	options_zoom = value



func _on_button_resume_pressed():
	_reset_continue()
	_set_visibility_with_tween(ui_ingame_menu, false)
	_set_visibility_with_tween(ui_ingame_overlay, true)
	control_paused = false


func _on_button_options_pressed():
	if %LevelLoader.cur_level == Constants.Level.STARTUP:
		_set_visibility_with_tween(ui_startup, false)
	else:
		_set_visibility_with_tween(ui_ingame_menu, false)
	_set_visibility_with_tween(ui_options)

func _on_button_levels_pressed():
	_reset_continue()
	_set_visibility_with_tween(ui_startup, false)
	_set_visibility_with_tween(ui_submenu_levels)

func _on_button_main_pressed():
	_reset_continue()
	_load_level(Constants.Level.STARTUP)
	_set_visibility_with_tween(ui_ingame_overlay, false)
	_set_visibility_with_tween(ui_final, false)
	_set_visibility_with_tween(ui_ingame_menu, false)
	_set_visibility_with_tween(ui_startup)


#STARTUP - Main Panel
func _on_button_play_pressed() -> void:
	_load_level(control_level)
	_set_visibility_with_tween(ui_ingame_end, false)
	_set_visibility_with_tween(ui_tutorial, false)
	_set_visibility_with_tween(ui_ingame_overlay, true)


# Exit for main and ingame


#Options Submenu
func _on_h_slider_volume_value_changed(value):
	options_volume_general = value


func _on_h_slider_music_value_changed(value):
	options_volume_music = value


func _on_button_options_back_pressed():
	_set_visibility_with_tween(ui_options, false)
	_set_visibility_with_tween(ui_submenu_levels, false)
	if %LevelLoader.cur_level == Constants.Level.STARTUP:
		_set_visibility_with_tween(ui_startup)
	else:
		_set_visibility_with_tween(ui_ingame_menu)

func _set_visibility_with_tween(nodes: Array[Node], show_node: bool = true, exclude_group:String="ui_spacer"):
	nodes.map(func(n): n.visible = show_node)
	var filtered_nodes = nodes.filter(func(n): return not n.is_in_group(exclude_group))
	filtered_nodes.map(func(n):
		var tween = n.create_tween().set_trans(Tween.TRANS_LINEAR)
		tween.tween_property(n, "self_modulate", Color(1, 1, 1, 1 if show_node else 0), 0.3)
	)


func _on_rock_pressed() -> void:
	merge_to.emit(Constants.CharacterType.ROCK)


func _on_paper_pressed() -> void:
	merge_to.emit(Constants.CharacterType.PAPER)


func _on_scissors_pressed() -> void:
	merge_to.emit(Constants.CharacterType.SCISSORS)


func _reset_continue():
	continue_pressed = false

var continue_timer = Timer.new()

var continue_pressed :bool = false

func _on_button_continue_pressed():
	if continue_pressed:
		return
	continue_pressed = true
	continue_timer.start(.2)
	_set_visibility_with_tween(ui_ingame_end, false)
	if control_game_loose:
		_load_level(Constants.Level.STARTUP)
		_set_visibility_with_tween(ui_ingame_overlay, false)
		_set_visibility_with_tween(ui_ingame_end, false)
		_set_visibility_with_tween(ui_startup)
	else:
		var lastlevel = %LevelLoader.load_next_level()
		if lastlevel == true:
			_set_visibility_with_tween(ui_ingame_overlay, false)
			_set_visibility_with_tween(ui_ingame_end, false)
			_set_visibility_with_tween(ui_final, true)
	control_game_loose = false
	control_game_won = false
	control_paused = false


func _on_button_play_tutorial_pressed():
	_set_visibility_with_tween(ui_startup, false)
	_set_visibility_with_tween(ui_tutorial, true)
	pass # Replace with function body.

func _unhandled_input(event):
	if event.is_action_pressed("camera_zoom_minus"):
		if options_zoom > 0:
			options_zoom -= 1
			ui_zoom_slider.set_value_no_signal(options_zoom)
			return
		else:
			return
	if event.is_action_pressed("camera_zoom_plus"):
		if options_zoom < 4:
			options_zoom += 1
			ui_zoom_slider.set_value_no_signal(options_zoom)
			return
		else:
			return

var human_count: int = 1

func _on_button_change_players_pressed() -> void:
	human_count += 1
	human_count = human_count % 4
	ui_human_count.text = var_to_str(human_count)
	ui_bot_count.text = var_to_str(3 - human_count)
