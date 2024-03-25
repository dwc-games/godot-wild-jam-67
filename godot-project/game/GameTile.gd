@tool
@icon("icons/hex.svg")
class_name GameTile extends Node3D

@export var grid_position: Vector2i = Vector2i.ZERO

@export var height_offset: float = 0.0

@export var image: Texture2D = null:
	set(value):
		image = value
		if image and hex_mesh:
			hex_mesh.material_override.albedo_texture = image

@export var normal: Texture2D = null:
	set(value):
		normal = value
		if normal and hex_mesh:
			hex_mesh.material_override.normal_texture = normal

var top_position: Node3D = null

var hex_mesh: MeshInstance3D = null

signal got_selected

var selected: bool = false:
	set(value):
		selected = value
		got_selected.emit()

var hover: bool = false:
	set(value):
		hover = value
		$HoverHighlight.visible = hover

var highlighted: bool = false:
	set(value):
		highlighted = value
		$Highlight.visible = highlighted


func get_top_position() -> Vector3:
	if top_position == null:
		return global_position
	return top_position.global_position


func _ready():
	_loadObjectsFromLevel()
	_setGlobalPosition(grid_position)
	selected = false
	$DebugLabel.visible = false
	image = image
	normal = normal


func _process(_delta):
	if Engine.is_editor_hint():
		_loadObjectsFromLevel()
		_setGlobalPosition(grid_position)
		$DebugLabel.text = (
			"x: " + var_to_str(grid_position.x) + ", y: " + var_to_str(grid_position.y)
		)
		$DebugLabel.visible = true


func _loadObjectsFromLevel():
	top_position = find_child("TopPosition")
	if not top_position:
		push_error("No top position found for tile ", self, " at " + str(grid_position))
	hex_mesh = find_child("hex")
	if not hex_mesh:
		push_error("No hex mesh found for tile ", self, " at " + str(grid_position))


const tile_radius: float = 1.0
const x_off: float = cos(deg_to_rad(30)) * tile_radius
const y_off: float = 1.5 * tile_radius


func _setGlobalPosition(pos: Vector2i) -> void:
	transform.origin = Vector3(
		pos.x * 2.0 * x_off + (0.0 if pos.y % 2 == 0 else x_off),
		height_offset,
		+1.0 * pos.y * y_off
	)


func _on_selection_area_input_event(
	_camera: Node, event: InputEvent, _position: Vector3, _normal: Vector3, _shape_idx: int
) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_MASK_LEFT:
			selected = true


func _on_selection_area_mouse_entered() -> void:
	hover = true


func _on_selection_area_mouse_exited() -> void:
	hover = false
