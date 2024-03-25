@tool
@icon("icons/pickup.svg")
class_name GamePickup extends Node3D

@export var current_tile: GameTile = null:
	set(value):
		current_tile = value

@export var pickup_type: Constants.PickupType = Constants.PickupType.DUPLICATE


func set_to_tile() -> void:
	if current_tile != null:
		transform.origin = current_tile.get_top_position()


func _process(_delta):
	if Engine.is_editor_hint():
		set_to_tile()
