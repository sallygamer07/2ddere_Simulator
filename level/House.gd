extends Node2D

export(String) var level_name = "House"

onready var navigation = get_node("Navigation2D")
onready var player = get_node("YSort/Player")
onready var FirstPos = get_node("FirstPos")

func _ready():
	Global.node_creation_parent = self
	Global.player.data["level"] = level_name
	Global.mainMenu = false
	Global.object_YSort = $YSort/Objects

	
	if Global.from_level != null:
		player.set_position(get_node(Global.from_level + "Pos").global_position)
	
	if Global.loaded == -1:
		player.set_position(FirstPos.global_position)
	
	
func _exit_tree():
	Global.node_creation_parent = null


func _process(_delta):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), GlobalSettings.music_volume)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), GlobalSettings.fx_volume)
#


func _on_GotoSchool_body_entered(body):
	if body is Player:
		Global.from_level = level_name
		player.save_def()
		SaveFile.save_file(0)
		Global.loaded = 0
		$Main.stop()
		$FadeScene.transition()


func _on_FadeScene_transitioned():
	SceneChanger.goto_scene("res://level/School.tscn", self)
