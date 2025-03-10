extends CharacterBody2D

var character_started = false
var ai_started = false
var direction_type = 0
var rising = true
var throw_counter = 0
var stun_counter = 0
var stunned = false
var grabbed = false
var grab_counter = 0
var throwing = true
var no_collisions = 0
var speed = 500
var outgoing_force = speed * 0.1
var lunge_counter = 0.0
var lunge_duration = 0.0
var lunging = false
var collision_counter = 0
var spacer = 0
var direction = Vector2.ZERO
var other_direction = Vector2.ZERO
var throw_dir = 0
var fumble = false
var pantick = 0.0
var throw_vector = Vector2.ZERO
var secondtick = false
var speedin = 0
var pantickset = 0.0
var rotdelay = 0.0
@onready var puck = get_parent().get_node("Puck")
@onready var timer = get_parent().get_node("Puck/Timer")
@onready var timeout = get_parent().get_node("Puck/Timeout")
@onready var puck_sprite = get_parent().get_node("Puck/Sprite2D")
@onready var control = get_parent().get_node("Control")
@onready var lunge_bar = get_parent().get_node("Control/LungeBar")
@onready var throw_bar = get_parent().get_node("Control/ThrowBar")
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var casper2 = get_parent().get_node("Area2D")
@onready var casper3 = get_parent().get_node("Area2D2")


func _physics_process(delta):
	#puck timeout logic
	if(puck.global_position.y > 600 && !character_started):
		ai_started = false
		Global.side_ai = false
		timeout.start()
		character_started = true
			
	if(puck.global_position.y < 600 && !ai_started):
		character_started = false
		Global.side_ai = true
		timeout.start()
		ai_started = true
		
		
	#update lunge bar
	lunge_bar.value = lunge_counter
	
	
	#MOVEMENT LOGIC
	#get velocity vector and convert to unit vector
	if(lunging == false):
		direction = Vector2(int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left")), int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up")))
		if(direction != Vector2.ZERO):
			direction_type = 0
			other_direction = direction
			direction = direction.normalized()
		else:
			animated_sprite.play("idle")
		
	if(direction.x > 0 && direction.y == 0):
		direction_type = 1
		animated_sprite.play("right")
	if(direction.x < 0 && direction.y == 0):
		direction_type = 2
		animated_sprite.play("left")
	if(direction.y > 0 && direction.x == 0):
		direction_type = 3
		animated_sprite.play("down")
	if(direction.y < 0 && direction.x == 0):
		direction_type = 4
		animated_sprite.play("up")
	if(direction.x > 0 && direction.y > 0):
		direction_type = 5
		animated_sprite.play("down")
	if(direction.x > 0 && direction.y < 0):
		direction_type = 6
		animated_sprite.play("up")
	if(direction.x < 0 && direction.y > 0):
		direction_type = 7
		animated_sprite.play("down")
	if(direction.x < 0 && direction.y < 0):
		direction_type = 8
		animated_sprite.play("up")
		
		
	#lunge cooldown counter
	if(Input.is_action_pressed("ui_lunge") == false && lunge_counter < 100.0):
		lunge_counter += 1.0
		
		
	#lunge mechanic
	if(Input.is_action_pressed("ui_lunge") == true && lunge_counter == 100.0 || lunge_duration > 0.0):
		print("lunging")
		if(lunging == false):
			lunge_duration = 10.0
		lunging = true
		lunge_counter = 0.0
		lunge_bar.value = lunge_bar.min_value
		speed = 1200
		if(lunge_duration > 0.0):
			lunge_duration -= 1.0
			if(lunge_duration <= 0.0):
				print("iermhcgerjkhbcgekjtrg")
				puck.set_collision_mask_value(4, true)
				set_collision_mask_value(3, true)
				lunging = false
				
	else:
		speed = 400
		
		
	#normal movement
	if(!grabbed && !stunned):
		velocity = direction * speed
		move_and_slide()
	if(!grabbed && grab_counter > 0):
		grab_counter -= 1
		$AnimatedSprite2D.self_modulate = Color(0, 0, 1)
		if(grab_counter == 0):
			$AnimatedSprite2D.self_modulate = Color(1, 1, 1)
			
			
	#throw collision disabling
	if(throwing):
		no_collisions -= 1
		if(no_collisions <= 0):
			puck.set_collision_mask_value(4, true)
			set_collision_mask_value(3, true)
			throwing = false
			no_collisions = 0



	#collision cooldown counter
	if(collision_counter > 0):
		collision_counter -= 1
		
		
	#puck critical speed sensing
	if(abs(puck.linear_velocity.length()) > abs(speed) * 3/4 && puck.linear_velocity.length() > 300 || velocity == Vector2.ZERO && puck.linear_velocity.length() >= 300):
		puck_sprite.self_modulate = Color(1, 0, 0)
	else:
		puck_sprite.self_modulate = Color(1, 1 , 1)
		
		
	#collision
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		if(collision.get_collider() is RigidBody2D && collision_counter == 0 && no_collisions <= 0):
			collision_counter = 50
			if(abs(puck.linear_velocity.length()) > abs(speed) * 3/4 && puck.linear_velocity.length() > 300 || velocity == Vector2.ZERO && puck.linear_velocity.length() >= 300):
				stunned = true
				stun_counter = 50
				velocity = Vector2.ZERO
				puck.set_collision_mask_value(4, false)
				set_collision_mask_value(3, false)
			else:
				if(lunging):
					collision.get_collider().apply_central_impulse(-collision.get_normal() * (outgoing_force * 3))
				else:
					collision.get_collider().apply_central_impulse(-collision.get_normal() * outgoing_force)
	
	
	#stun timing decrementation		
	if(stunned && stun_counter > 0):
		stun_counter -= 1
		if(stun_counter <= 0):
			stunned = false
			
			
	#TO-DO while grabbed -> throw arrow rotation logic and direction vector/arrow calculation
	if(grabbed):
		spacer -= 1
		$Arrow.visible = true
		print("GRABBED")
		pantick-=delta
		if(rotdelay > 0.0):
			rotdelay -= delta
		else:
			rotdelay = 0.0
			if(fumble):
				_throw()
			if(pantick <= 0):
				pantick = pantickset
				if(throw_dir < 35):
					throw_dir += 1
				else:
					throw_dir = 0
					fumble = true


		if(throw_dir == 0):
			throw_vector = (Vector2(0,-1.0).normalized())
			$Arrow.position = throw_vector * 100
			$Arrow.rotation_degrees = 0
			
		if(throw_dir == 1):
			throw_vector = (Vector2(0.17364817766693041,-0.984807753012208).normalized())
			$Arrow.position = throw_vector * 100
			$Arrow.rotation_degrees = 10
		if(throw_dir == 2):
			throw_vector = (Vector2(0.3420201433256688,-0.9396926207859083).normalized())
			$Arrow.position = throw_vector * 100
			$Arrow.rotation_degrees = 20
		if(throw_dir == 3):
			throw_vector = (Vector2(0.5,-0.8660254037844386).normalized())
			$Arrow.position = throw_vector * 100
			$Arrow.rotation_degrees = 30
		if(throw_dir == 4):
			throw_vector = (Vector2(0.6427876096865394,-0.766044443118978).normalized())
			$Arrow.position = throw_vector * 100
			$Arrow.rotation_degrees = 40
		if(throw_dir == 5):
			throw_vector = (Vector2(0.766044443118978,-0.6427876096865393).normalized())
			$Arrow.position = throw_vector * 100
			$Arrow.rotation_degrees = 50
		if(throw_dir == 6):
			throw_vector = (Vector2(0.8660254037844387,-0.5).normalized())
			$Arrow.position = throw_vector * 100
			$Arrow.rotation_degrees = 60
		if(throw_dir == 7):
			throw_vector = (Vector2(0.9396926207859084,-0.3420201433256687).normalized())
			$Arrow.position = throw_vector * 100
			$Arrow.rotation_degrees = 70
		if(throw_dir == 8):
			throw_vector = (Vector2(0.984807753012208,-0.17364817766693033).normalized())
			$Arrow.position = throw_vector * 100
			$Arrow.rotation_degrees = 80
		if(throw_dir == 9):
			throw_vector = (Vector2(1.0,0).normalized())
			$Arrow.position = throw_vector * 100
			$Arrow.rotation_degrees = 90
			
		if(throw_dir == 17):
			throw_vector = (Vector2(0.17364817766693041,0.984807753012208).normalized())
			$Arrow.position = throw_vector * 100
			$Arrow.rotation_degrees = 170
		if(throw_dir == 16):
			throw_vector = (Vector2(0.3420201433256688,0.9396926207859083).normalized())
			$Arrow.position = throw_vector * 100
			$Arrow.rotation_degrees = 160
		if(throw_dir == 15):
			throw_vector = (Vector2(0.5,0.8660254037844386).normalized())
			$Arrow.position = throw_vector * 100
			$Arrow.rotation_degrees = 150
		if(throw_dir == 14):
			throw_vector = (Vector2(0.6427876096865394,0.766044443118978).normalized())
			$Arrow.position = throw_vector * 100
			$Arrow.rotation_degrees = 140
		if(throw_dir == 13):
			throw_vector = (Vector2(0.766044443118978,0.6427876096865393).normalized())
			$Arrow.position = throw_vector * 100
			$Arrow.rotation_degrees = 130
		if(throw_dir == 12):
			throw_vector = (Vector2(0.8660254037844387,0.5).normalized())
			$Arrow.position = throw_vector * 100
			$Arrow.rotation_degrees = 120
		if(throw_dir == 11):
			throw_vector = (Vector2(0.9396926207859084,0.3420201433256687).normalized())
			$Arrow.position = throw_vector * 100
			$Arrow.rotation_degrees = 110
		if(throw_dir == 10):
			throw_vector = (Vector2(0.984807753012208,0.17364817766693033).normalized())
			$Arrow.position = throw_vector * 100
			$Arrow.rotation_degrees = 100
		if(throw_dir == 18):
			throw_vector = (Vector2(0.0,1.0).normalized())
			$Arrow.position = throw_vector * 100
			$Arrow.rotation_degrees = 180
		
		if(throw_dir == 19):
			throw_vector = (Vector2(-0.17364817766693041,0.984807753012208).normalized())
			$Arrow.position = throw_vector * 100
			$Arrow.rotation_degrees = -170
		if(throw_dir == 20):
			throw_vector = (Vector2(-0.3420201433256688,0.9396926207859083).normalized())
			$Arrow.position = throw_vector * 100
			$Arrow.rotation_degrees = -160
		if(throw_dir == 21):
			throw_vector = (Vector2(-0.5000000000000001,0.8660254037844386).normalized())
			$Arrow.position = throw_vector * 100
			$Arrow.rotation_degrees = -150
		if(throw_dir == 22):
			throw_vector = (Vector2(-0.6427876096865394,0.766044443118978).normalized())
			$Arrow.position = throw_vector * 100
			$Arrow.rotation_degrees = -140
		if(throw_dir == 23):
			throw_vector = (Vector2(-0.766044443118978,0.6427876096865393).normalized())
			$Arrow.position = throw_vector * 100
			$Arrow.rotation_degrees = -130
		if(throw_dir == 24):
			throw_vector = (Vector2(-0.8660254037844387,0.5).normalized())
			$Arrow.position = throw_vector * 100
			$Arrow.rotation_degrees = -120
		if(throw_dir == 25):
			throw_vector = (Vector2(-0.9396926207859084,0.3420201433256687).normalized())
			$Arrow.position = throw_vector * 100
			$Arrow.rotation_degrees = -110
		if(throw_dir == 26):
			throw_vector = (Vector2(-0.984807753012208,0.17364817766693033).normalized())
			$Arrow.position = throw_vector * 100
			$Arrow.rotation_degrees = -100
		if(throw_dir == 27):
			throw_vector = (Vector2(-1.0,0).normalized())
			$Arrow.position = throw_vector * 100
			$Arrow.rotation_degrees = -90
			
		if(throw_dir == 35):
			throw_vector = (Vector2(-0.17364817766693041,-0.984807753012208).normalized())
			$Arrow.position = throw_vector * 100
			$Arrow.rotation_degrees = -10
		if(throw_dir == 34):
			throw_vector = (Vector2(-0.3420201433256688,-0.9396926207859083).normalized())
			$Arrow.position = throw_vector * 100
			$Arrow.rotation_degrees = -20
		if(throw_dir == 33):
			throw_vector = (Vector2(-0.5000000000000001,-0.8660254037844386).normalized())
			$Arrow.position = throw_vector * 100
			$Arrow.rotation_degrees = -30
		if(throw_dir == 32):
			throw_vector = (Vector2(-0.6427876096865394,-0.766044443118978).normalized())
			$Arrow.position = throw_vector * 100
			$Arrow.rotation_degrees = -40
		if(throw_dir == 31):
			throw_vector = (Vector2(-0.766044443118978,-0.6427876096865393).normalized())
			$Arrow.position = throw_vector * 100
			$Arrow.rotation_degrees = -50
		if(throw_dir == 30):
			throw_vector = (Vector2(-0.8660254037844387,-0.5).normalized())
			$Arrow.position = throw_vector * 100
			$Arrow.rotation_degrees = -60
		if(throw_dir == 29):
			throw_vector = (Vector2(-0.9396926207859084,-0.3420201433256687).normalized())
			$Arrow.position = throw_vector * 100
			$Arrow.rotation_degrees = -70
		if(throw_dir == 28):
			throw_vector = (Vector2(-0.984807753012208,-0.17364817766693033).normalized())
			$Arrow.position = throw_vector * 100
			$Arrow.rotation_degrees = -80

			
	
	#grab initialization
	if(!puck.complete && Input.is_action_pressed("ui_grab") && grab_counter == 0):
		_grab()
	
	#throw initialization
	if(puck.complete && Input.is_action_just_pressed("ui_grab")):
		_throw()
		
		
func _grab():
	if(puck.in_range && !puck.complete && Input.is_action_pressed("ui_grab") && !stunned):
		spacer = 3
		speedin = puck.linear_velocity.length()
		setpantick()
		puck.complete = true
		print("grab!")
		puck.linear_velocity = Vector2.ZERO
		grabbed = true
		rotdelay = 0.1
		throw_dir = 0
		puck.freeze = true
		puck.scale.x = 0.5
		puck.scale.y = 0.5
		puck.global_position = global_position
		
func _throw():
	if(spacer <= 0):
		spacer = 0
		$Arrow.visible = false
		throw_bar.visible = false
		puck.complete = false
		grabbed = false
		puck.freeze = false
		grab_counter = 50
		throwing = true
		pantick = 0.0
		fumble = false
		no_collisions = 150
		puck.set_collision_mask_value(4, false)
		set_collision_mask_value(3, false)
		puck.scale.x = 1
		puck.scale.y = 1
		if(speedin < 300):
			puck.linear_velocity = (600) * throw_vector
		else:
			puck.linear_velocity = (speedin + 300) * throw_vector
		throw_counter = 0
		puck.global_position.x = global_position.x 
		puck.global_position.y = global_position.y


func _on_timeout_timeout():
	if(Global.side_ai == false):
		print("P2 Scored")
		Global.bot_score += 1
		control._update_bot_score()
		if(Global.bot_score >= 7):
			Global.user_score = 0
			Global.bot_score = 0
			Global.top_player_win = true
			get_tree().change_scene_to_file("res://scenes/WinScreen.tscn")
		else:
			timer.start()
	else:
		print("P1 Scored")
		Global.user_score += 1
		control._update_user_score()
		if(Global.user_score >= 7):
			Global.user_score = 0
			Global.bot_score = 0
			Global.bottom_player_win = true
			get_tree().change_scene_to_file("res://scenes/WinScreen.tscn")
		else:
			timer.start()

func setpantick():
	if(speedin > 1000):
		speedin = 1000
	if(speedin < 100):
		speedin = 100
	#normalize range
	pantickset = 0.04 - ((speedin - 100)/900 * 0.035)
