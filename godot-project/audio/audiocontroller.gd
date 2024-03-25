class_name AudioController
extends Node

@export var volume_music: int
@export var volume_general: int

@onready var audio_stream_player_music = $AudioStreamPlayer_music

var audio_stream_player_firstplay: bool = true
#Music Streams
var audio_stream_music_intro = preload("res://audio/resources/Intro.ogg")
var audio_stream_music_loop = preload("res://audio/resources/Loop.ogg")


func _ready():
	pass


func _process(_delta):
	var volume_music_db = remap(volume_music, 0.0, 100.0, -60.0, 0.0)
	audio_stream_player_music.set_volume_db(volume_music_db)
	if audio_stream_player_firstplay and not audio_stream_player_music.is_playing():
		audio_stream_player_music.set_stream(audio_stream_music_intro)
		audio_stream_player_music.play()
		audio_stream_player_firstplay = false
		print("Intro")

	if not audio_stream_player_music.is_playing() and not audio_stream_player_firstplay:
		audio_stream_player_music.set_stream(audio_stream_music_loop)
		audio_stream_player_music.play()
		print("Loop")

	var volume_general_db = remap(volume_general, 0.0, 100.0, -60.0, 0.0)
	AudioServer.set_bus_volume_db(0, volume_general_db)
