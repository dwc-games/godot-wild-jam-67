extends Node

@export var audio: AudioController
@export var ui: UserInterface


# Called when the node enters the scene tree for the first time.
func _ready():
	pass  # Replace with function body.


func _process(_delta):
	#Send to Audio
	audio.volume_general = ui.options_volume_general
	audio.volume_music = ui.options_volume_music

	#Send to UI
