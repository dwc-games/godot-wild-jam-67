@tool
class_name GameCharacterStatus extends Node3D

var action_points: int = 0:
	set(value):
		action_points = value
		$ActionPoint.frame = clampi(action_points, 0, 1)
