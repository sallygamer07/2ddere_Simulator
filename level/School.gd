extends Node2D

export(String) var level_name = "School"

onready var navigation = get_node("Navigation2D")
onready var player = get_node("YSort/Player")
onready var schoolDoorPos = get_node("schoolDoorPos")

func _ready():
	Global.node_creation_parent = self
	Global.player.data["level"] = level_name
	Global.mainMenu = false
	Global.object_YSort = $YSort/Objects

	
	if Global.from_level != null:
		Global.player.set_position(get_node(Global.from_level + "Pos").global_position)
	
func _exit_tree():
	Global.node_creation_parent = null


func _process(_delta):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), GlobalSettings.music_volume)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), GlobalSettings.fx_volume)
#
#	if Global.player != null:
#		if Global.player.health <= 20:
#			$Main.set_pitch_scale(0.5)
#
#		elif Global.player.health >= 21:
#			$Main.set_pitch_scale(1.0)
#yandere meter
