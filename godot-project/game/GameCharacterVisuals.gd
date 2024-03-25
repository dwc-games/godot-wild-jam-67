@tool
class_name GameCharacterVisuals extends Node3D

var collector: Sprite3D = null:
	get:
		if not collector:
			collector = find_child("Collector") as Sprite3D
		return collector
var warden: Sprite3D = null:
	get:
		if not warden:
			warden = find_child("Warden") as Sprite3D
		return warden
var sucker: Sprite3D = null:
	get:
		if not sucker:
			sucker = find_child("Sucker") as Sprite3D
		return sucker

var action_point: AnimatedSprite3D = null:
	get:
		if not action_point:
			action_point = find_child("ActionPoint") as AnimatedSprite3D
		return action_point

var rock_paper_scissors: AnimatedSprite3D = null:
	get:
		if not rock_paper_scissors:
			rock_paper_scissors = find_child("RockPaperScissors") as AnimatedSprite3D
		return rock_paper_scissors

@export var show_action_point: bool = false:
	set(value):
		show_action_point = value
		if action_point:
			action_point.visible = show_action_point

@export var action_points: int = 0:
	set(value):
		action_points = value
		if action_point:
			action_point.frame = clampi(action_points, 0, 1)

@export var character_fraction: Constants.CharacterFraction = Constants.CharacterFraction.COLLECTOR:
	set(value):
		character_fraction = value
		if collector and warden and sucker:
			collector.visible = character_fraction == Constants.CharacterFraction.COLLECTOR
			warden.visible = character_fraction == Constants.CharacterFraction.WARDEN
			sucker.visible = character_fraction == Constants.CharacterFraction.SUCKER

@export var character_type: Constants.CharacterType = Constants.CharacterType.ROCK:
	set(value):
		character_type = value
		if rock_paper_scissors:
			rock_paper_scissors.frame = character_type


func _ready() -> void:
	_refresh_children()


func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		# _refresh_children()
		pass


func _refresh_children() -> void:
	character_fraction = character_fraction
	character_type = character_type
	action_points = action_points
	show_action_point = show_action_point
