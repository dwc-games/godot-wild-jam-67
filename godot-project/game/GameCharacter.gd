@tool
@icon("icons/char.svg")
class_name GameCharacter extends Node3D

@export var audio_player: AudioStreamPlayer3D

@export var sound_attack: Array[AudioStream] = []
@export var sound_consume: Array[AudioStream] = []
@export var sound_move: Array[AudioStream] = []

@export var player_id: int = 0
@export var current_tile: GameTile

@export var character_fraction: Constants.CharacterFraction = Constants.CharacterFraction.COLLECTOR:
	set(value):
		character_fraction = value
		if character_visual:
			character_visual.character_fraction = character_fraction

@export var character_type: Constants.CharacterType = Constants.CharacterType.ROCK:
	set(value):
		character_type = value
		if character_visual:
			character_visual.character_type = character_type

signal kill_me

signal got_selected
@export var selected: bool = false:
	set(value):
		selected = value
		$Selected.visible = selected
		if selected:
			got_selected.emit()

var highlighted: bool = false:
	set(value):
		highlighted = value
		$Highlight.visible = highlighted

@export var show_status: bool = false:
	set(value):
		show_status = value
		if character_visual:
			character_visual.show_action_point = show_status

@export var player_colors: Array[Material] = []
@export var selected_color: Material = null

@export var action_points: int = 0:
	set(value):
		action_points = value
		if character_visual:
			character_visual.action_points = action_points

var character_visual: GameCharacterVisuals = null:
	get:
		if not character_visual:
			var children = find_children("*", "GameCharacterVisuals")
			if children.size() == 1:
				character_visual = children[0]
		return character_visual


func _ready():
	character_fraction = character_fraction
	character_type = character_type


func _process(_delta):
	if Engine.is_editor_hint():
		_placeOnTile()
		character_fraction = character_fraction
		character_type = character_type
	_set_border_color()


func _placeOnTile() -> void:
	if current_tile != null:
		transform.origin = current_tile.get_top_position()


func consume_pickup_sound():
	if is_instance_valid(audio_player):
		audio_player.set_stream(sound_consume[randi() % sound_consume.size()])
		audio_player.play()


func move_to_tile(tile: GameTile, use_action_point: bool = true):
	if use_action_point:
		if is_instance_valid(audio_player):
			audio_player.set_stream(sound_move[randi() % sound_move.size()])
			audio_player.play()
		action_points -= 1
	current_tile = tile
	var tween = self.create_tween().set_trans(Tween.TRANS_BOUNCE)
	tween.tween_method(_set_my_position, self.position, tile.get_top_position(), 0.3)


var _attack: bool = false


func attack(target: GameCharacter):
	if is_instance_valid(audio_player):
		audio_player.set_stream(sound_attack[randi() % sound_attack.size()])
		audio_player.play()
	action_points -= 1
	_attack = true
	var target_tile = target.current_tile
	print(self, " attacks ", target, " on tile ", target_tile)
	if _do_i_win(target.character_type):
		target.kill_me.emit()
		move_to_tile(target_tile, false)
	if _do_i_lose(target.character_type):
		kill_me.emit()


func _do_i_win(against: Constants.CharacterType) -> bool:
	if (
		character_type == Constants.CharacterType.ROCK
		and against == Constants.CharacterType.SCISSORS
	):
		return true
	elif (
		character_type == Constants.CharacterType.PAPER and against == Constants.CharacterType.ROCK
	):
		return true
	elif (
		character_type == Constants.CharacterType.SCISSORS
		and against == Constants.CharacterType.PAPER
	):
		return true
	else:
		return false


func _do_i_lose(against: Constants.CharacterType) -> bool:
	if character_type == Constants.CharacterType.ROCK and against == Constants.CharacterType.PAPER:
		return true
	elif (
		character_type == Constants.CharacterType.PAPER
		and against == Constants.CharacterType.SCISSORS
	):
		return true
	elif (
		character_type == Constants.CharacterType.SCISSORS
		and against == Constants.CharacterType.ROCK
	):
		return true
	else:
		return false


func _set_my_position(new_position: Vector3):
	self.position = new_position


func _on_selection_area_input_event(
	_camera: Node, event: InputEvent, _position: Vector3, _normal: Vector3, _shape_idx: int
) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_MASK_LEFT:
			selected = not selected


func _set_border_color():
	if player_colors.size() > 0 and player_id < player_colors.size():
		$HexBorder.material_override = player_colors[player_id]
