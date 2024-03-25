@tool
class_name GameCamera extends Camera3D

@export var maxPosition: Vector3 = Vector3(10, 12, 10)
@export var minPosition: Vector3 = Vector3(-10, 3, -10)

const height_xangle: Array[Vector2] = [
	Vector2(3, -35), Vector2(5, -40), Vector2(7, -50), Vector2(11, -60), Vector2(15, -75)
]

@export var zoom_level: int = 1:
	set(value):
		zoom_level = clampi(value, 0, 4)
		set_zoom(zoom_level)


func _ready() -> void:
	zoom_level = zoom_level


func set_zoom(level: int) -> void:
	position.y = height_xangle[level].x
	rotation.x = deg_to_rad(height_xangle[level].y)


func _process(_delta: float) -> void:
	var clamped_position = Vector3(
		clamp(position.x, minPosition.x, maxPosition.x),
		clamp(position.y, minPosition.y, maxPosition.y),
		clamp(position.z, minPosition.z, maxPosition.z)
	)
	position = clamped_position


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if (
			event.button_mask == MOUSE_BUTTON_MASK_LEFT
			|| event.button_mask == MOUSE_BUTTON_MASK_RIGHT
			|| event.button_mask == MOUSE_BUTTON_MASK_MIDDLE
		):
			position -= (
				Vector3(event.relative.x, 0, event.relative.y) / 100.0 * (1.0 + zoom_level / 2.0)
			)
	if event is InputEventScreenDrag:
		position -= Vector3(event.relative.x, 0, event.relative.y) / 100 * (1.0 + zoom_level / 2.0)
	if event is InputEventKey:
		if event.is_pressed():
			match event.keycode:
				KEY_W:
					position -= Vector3(0, 0, 1)
				KEY_S:
					position += Vector3(0, 0, 1)
				KEY_A:
					position -= Vector3(1, 0, 0)
				KEY_D:
					position += Vector3(1, 0, 0)
