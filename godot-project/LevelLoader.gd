class_name LevelLoader extends Node3D

var TestLevel: Resource = preload("res://game/levels/test.tscn")
var SkinLevel: Resource = preload("res://game/levels/skin.tscn")
var BloodLevel: Resource = preload("res://game/levels/blood.tscn")
var BBBLevel: Resource = preload("res://game/levels/bbb.tscn")
var NeuralLevel: Resource = preload("res://game/levels/neural.tscn")
var StartUp: Resource = preload("res://startup/startup.tscn")
var active_levels: Array[Constants.Level] = [Constants.Level.SKIN,Constants.Level.BLOOD,Constants.Level.BRAIN,Constants.Level.NEURAL]

var cur_level: Constants.Level = Constants.Level.STARTUP

func _ready():
	load_level(cur_level)

	
func load_next_level():
	var lastlevel:Constants.Level
	for levels in active_levels:
		lastlevel = levels
	
	if cur_level == lastlevel:
		return true
	else:
		var  next_level = active_levels[cur_level]
		load_level(next_level)

	
func load_level(level: Constants.Level) -> void:
	print("Loading level: ", Constants.Level.keys()[level])
	cur_level = level
	for child in get_children():
		child.queue_free()
	match level:
		Constants.Level.TEST:
			var test = TestLevel.instantiate()
			add_child(test)
		Constants.Level.STARTUP:
			var start = StartUp.instantiate()
			add_child(start)
		Constants.Level.SKIN:
			var skin = SkinLevel.instantiate()
			add_child(skin)
		Constants.Level.BLOOD:
			var test = BloodLevel.instantiate()
			add_child(test)
		Constants.Level.BRAIN:
			var start = BBBLevel.instantiate()
			add_child(start)
		Constants.Level.NEURAL:
			var skin = NeuralLevel.instantiate()
			add_child(skin)
		_:
			print("Level not found")
