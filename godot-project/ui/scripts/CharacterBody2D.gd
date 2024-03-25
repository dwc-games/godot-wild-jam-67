extends CharacterBody2D



# Get the gravity from the project settings to be synced with RigidBody nodes.
# var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


var speed = 400
var mouse_position = null

var mousepositoion
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	velocity = Vector2(0, 0)
	mouse_position = get_local_mouse_position()
	var direction = (mouse_position - position).normalized()
	velocity = (direction * speed)
	move_and_slide()
	pass

