extends KinematicBody2D

export var rival_name = ""

onready var anim = get_node("AnimationPlayer")
onready var playerDetectionZone : Area2D = get_node("PlayerDetectionZone")
onready var area = get_node("area")
onready var nav = get_node("../../Navigation2D")
onready var schoolDoor = get_node("../../schoolDoorPos")
onready var HomeDoor = get_node("../../HomeDoorPos")
onready var interectLabel = get_node("InterectE")
onready var dialogTimer = get_node("dialogTimer")
onready var doubtTimer = get_node("doubtTimer")

enum {
	IDLE,
	WALK,
	CHASE,
	GOTOSCHOOL,
	GOTOHOME,
	FOLLOW,
	DOUBT, #의심
	RUN, #도망
	SIT,
	DEAD
}

var state = IDLE

var speed = 0
var walk_speed = 80
var run_speed = 160
var fri = 200
var acc = 300

var vel = Vector2.ZERO

var path : Array = []

var previous_state = null

func _ready():
	state = GOTOSCHOOL
	area.connect("body_entered", self, "on_body_entered")
	area.connect("body_exited", self, "on_body_exited")
	
	interectLabel.hide()
	
func _physics_process(_delta):
	match state:
		IDLE:
			vel = vel.move_toward(Vector2.ZERO, fri * _delta)
			anim.play("Idle")
			
			seek_player()
			
		WALK:
			speed = walk_speed
			anim.play("Run")
			seek_player()
			
		CHASE:
			var player = playerDetectionZone.player
			get_target_path(player.global_position)
			if player != null:
				if path.size() > 2:
					move_to_path(_delta)
			else:
				state = IDLE
			speed = run_speed
			anim.play("Run")
			
		FOLLOW:
			speed = walk_speed
			anim.play("Run")
			get_target_path(Global.player.global_position)
			if path.size() > 2:
				move_to_path(_delta)
			else:
				state = IDLE
			
		GOTOSCHOOL:
			speed = walk_speed
			anim.play("Run")
			get_target_path(schoolDoor.global_position)
			if path.size() > 2:
				move_to_path(_delta)
			else:
				state = IDLE
			
		GOTOHOME:
			speed = walk_speed
			anim.play("Run")
			get_target_path(HomeDoor.global_position)
			if path.size() > 2:
				move_to_path(_delta)
			else:
				self.queue_free()
		
		DOUBT:
			anim.play("Idle")
			vel = vel.move_toward(Vector2.ZERO, fri * _delta)
			if doubtTimer.time_left <= 0:
				doubtTimer.one_shot = true
				doubtTimer.start(3)
				yield(doubtTimer, "timeout")
				state = previous_state
				previous_state = null
				playerDetectionZone.monitorable = false
			
			
		RUN:
			speed = run_speed
			anim.play("Run")
			
		SIT:
			vel = vel.move_toward(Vector2.ZERO, fri * _delta)
			anim.play("Sit")
		
		DEAD:
			vel = vel.move_toward(Vector2.ZERO, fri * _delta)
			
	vel = move_and_slide(vel)
	
	if playerDetectionZone.can_see_player():
		if playerDetectionZone.player.state == playerDetectionZone.player.states.LAUGH:
			previous_state = state
			state = DOUBT
			
	
	if interectLabel.visible == true:
		if Input.is_action_pressed("interect"):
			if path.size() > 2:
				Dialogs.show_dialog("I'm Busy!")
			else:
				previous_state = state
				state = IDLE
				Dialogs.show_dialog("What's up?")
				if dialogTimer.time_left <= 0:
					dialogTimer.start(3)
					dialogTimer.connect("timeout", self, "on_dialogTimer_timeout")
				
					
func on_dialogTimer_timeout():
	Dialogs.dialog_box.hide()
	state = previous_state
	previous_state = null
	
func seek_player():
	if playerDetectionZone.can_see_player():
		if playerDetectionZone.player.state == playerDetectionZone.player.states.KILL:
			if self.is_in_group("RUN"):
				state = RUN
			elif self.is_in_group("CHASE"):
				state = CHASE
			
func move_to_path(_delta):
	vel = global_position.direction_to(path[1]) * speed
	
func get_target_path(target_pos):
	path = nav.get_simple_path(global_position, target_pos, false)
			
func on_body_entered(body):
	if body is Player:
		interectLabel.show()
			
func on_body_exited(_body):
	if _body is Player:
		interectLabel.hide()
	
