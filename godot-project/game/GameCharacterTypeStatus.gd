@tool
class_name GameCharacterTypeStatus extends Node3D

var character_type: Constants.CharacterType = Constants.CharacterType.ROCK:
	set(value):
		character_type = value
		$Rock.visible = character_type == Constants.CharacterType.ROCK
		$Paper.visible = character_type == Constants.CharacterType.PAPER
		$Scissors.visible = character_type == Constants.CharacterType.SCISSORS


func _ready():
	character_type = character_type


func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		character_type = character_type
