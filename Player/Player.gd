extends KinematicBody2D
class_name Player

signal player_die

#meter가 낮아지면 Idle animation speed도 UP


const FRICTION : float = 0.15

export(int) var acc = 40
export(int) var max_speed = 100

onready var anim = $AnimationPlayer
onready var animated_sprite = $AnimatedSprite
onready var weapons : Node2D = get_node("Weapons")
onready var fade = preload("res://UI/FadeScene.tscn")
onready var laughAudio = $Laugh
onready var laughEffect = $LaughEffect

var current_weapon : Node2D

var dir = Vector2.ZERO
var vel = Vector2.ZERO

var speed = 0
var coin

var strength
var agility
var intellect
var wisdom
var constitution
var dexterity

var stat_point

var attacking = false

var player_dead = false

var is_sitting = false

var house = null setget set_house
var sitArea = null setget set_sitArea


enum states {
	IDLE,
	WALK,
	DISCOVERED, #들키다
	KILL,
	SNAP, #Snap mode
	SIT,
	LAUGH, #웃음
	SLEEP
}

var state = states.IDLE

var ctrl_num = 0

var data = {
		"strength" : 5,
		"agility" : 5,
		"intellect" : 5,
		"wisdom" : 5,
		"constitution" : 5,
		"dexterity" : 5,
		"x" : 1128,
		"y" : 1376,
		"level" : "Level_1",
		"coin" : 1000000,
		"stat_point" : 5,
		"quests" : {},
		"hotbar" : PlayerInventory.hotbar,
		"day" : Global.day
	}

func _ready() -> void:
	Global.player = self
	if SaveFile.is_file_there(Global.loaded):
		SaveFile.load_file(Global.loaded)
		data = SaveFile._player_data
	load_def()
	
	current_weapon = weapons.get_child(0)
	
#	if not (
#			Dialogs.connect("slog_started", self, "_on_dialog_started") == OK and
#			Dialogs.connect("dialog_ended", self, "_on_dialog_ended") == OK ):
#		printerr("Error connecting to dialog system")
	
	set_speed()
	set_house(null)
	set_sitArea(null)
	
	
func set_house(new_house):
	house = new_house
	
func set_sitArea(new_sitArea):
	sitArea = new_sitArea
	
func set_speed():
	speed = max_speed + agility * 4
	

func load_def():
	coin = data["coin"]
	stat_point = data["stat_point"]
	strength = data["strength"]
	agility = data["agility"]
	intellect = data["intellect"]
	wisdom = data["wisdom"]
	constitution = data["constitution"]
	dexterity = data["dexterity"]
	Quest.quest_list = data["quests"]
	PlayerInventory.hotbar = data["hotbar"]
	position.x = data["x"]
	position.y = data["y"]
	Global.day = data["day"]
	
	
func save_def():
	data["x"] = position.x
	data["y"] = position.y
	data["level"] = get_parent().get_parent().name
	data["coin"] = coin
	data["hotbar"] = PlayerInventory.hotbar
	data["quests"] = Quest.quest_list
	data["strength"] = strength
	data["agility"] = agility
	data["wisdom"] = wisdom
	data["intellect"] = intellect
	data["constitution"] = constitution
	data["dexterity"] = dexterity
	data["stat_point"] = stat_point
	data["day"] = Global.day


func _physics_process(_delta):
	if Global.active == false or Global.active_shop == false:
		if is_sitting == false:
			vel = move_and_slide(vel, dir, false)
#			for index in get_slide_count():
#				var collision = get_slide_collision(index)
#				var collider = collision.collider
#				var remainder = collision.remainder
				
#				if collider != null:
#					if collider is WoodenBox:
#						collider.move_and_collide(remainder) # move block by remainder

						
			vel = lerp(vel, Vector2.ZERO, FRICTION)
			
			get_input()
			
			if dir == Vector2.ZERO:
				state = states.IDLE

				
			if house != null:
				$interectE.show()
			else:
				$interectE.hide()
				
			if sitArea != null:
				$interecttoSit.show()
			else:
				$interecttoSit.hide()
		
	_state()
	
	var mouse_dir : Vector2 = (get_global_mouse_position() - global_position).normalized()
	
	if mouse_dir.x > 0 and animated_sprite.flip_h:
		animated_sprite.flip_h = false
	elif mouse_dir.x < 0 and not animated_sprite.flip_h:
		animated_sprite.flip_h = true	
		
	if current_weapon != null:
		current_weapon.move(mouse_dir)
		current_weapon.get_input()
		
	if Input.is_action_just_pressed("interect") and sitArea != null:
		var previous_pos : Vector2 = global_position
		if is_sitting == false:
			state = states.SIT
			is_sitting = true
			global_position = sitArea.sitPos.global_position
			$interectEtoSit.text = "[E]키를 눌러 일어서기"

		else:
			state = states.IDLE
			is_sitting = false
			global_position = previous_pos
			$interectEtoSit.text = "[E]키를 눌러 앉기"


func get_input() -> void:
	dir = Vector2.ZERO
	if Input.is_action_pressed("up"):
		dir += Vector2.UP
		move()
	if Input.is_action_pressed("down"):
		dir += Vector2.DOWN
		move()
	if Input.is_action_pressed("left"):
		dir += Vector2.LEFT
		move()
	if Input.is_action_pressed("right"):
		dir += Vector2.RIGHT
		move()

	if current_weapon != null:
		current_weapon.get_input()
		
	if Input.is_action_just_pressed("interect") and house != null:
		Global.player_pos = global_position
		house.enter()
		
	if Input.is_action_pressed("Run"):
		max_speed = 250
		set_speed()
	if Input.is_action_just_released("Run"):
		max_speed = 100
		set_speed()
		
	if Input.is_action_just_pressed("laugh"):
		state = states.LAUGH
		laughEffect.emitting = true
		laughAudio.play()
		
	if Input.is_action_just_released("laugh"):
		state = states.IDLE
		laughAudio.stop()


func switch_weapon() -> void:
	var slot = get_tree().root.get_node("/root/" + get_parent().get_parent().name + "/CanvasLayer/UI/HotBar/HotBarSlots").get_children()
	var weapon_name = slot[PlayerInventory.active_item_slot].item
	if weapon_name != null:
		var weapon_category = JsonData.item_data[weapon_name.item_name]["ItemCategory"]

		if weapon_category == "Sword":
			if current_weapon != null:
				current_weapon.hide()
			current_weapon = weapons.get_node(weapon_name.item_name)
			Global.player_weapon = "Sword"
			current_weapon.show()
			
	else:
		Global.player_weapon = null
		if current_weapon != null:
			current_weapon.hide()
		current_weapon = null


func move() -> void:
	dir = dir.normalized()
	vel += dir * acc
	vel = vel.clamped(speed)
	state = states.WALK

	if $FootStepTimer.time_left <= 0:
		$AudioStreamPlayer.pitch_scale = rand_range(0.8, 1)
		$AudioStreamPlayer.play()
		$FootStepTimer.start(0.3)
	
func _state() -> void:
	if state == states.IDLE:
		anim.play("Idle")

	if state == states.WALK:
		anim.play("Run")
		
	if state == states.SIT:
		anim.play("sit")
		
	if state == states.LAUGH:
		anim.play("Idle")
		
	if state == states.DISCOVERED:
		anim.play("Idle")

func _on_dialog_started():
	pass

func _on_dialog_ended():
	pass
	

func _on_HurtBox_area_entered(area):
	if area != null:
		on_player_die()


func on_player_die():
	player_dead = true
	var fade_ins = fade.instance()
	add_child(fade_ins)
	fade_ins.transition()
	fade_ins.connect("transitioned", self, "on_transitioned")
		
func on_transitioned():
	Global.player = null
	queue_free()
	SceneChanger.goto_scene("res://level/GameOver.tscn", get_parent().get_parent())
