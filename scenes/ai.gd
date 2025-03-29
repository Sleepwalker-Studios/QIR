extends CharacterBody2D
class_name ai
@onready var puck = get_parent().get_node("Puck")
@onready var bar = get_parent().get_node("BarrierTop")

var probability = 0
var direction_type = 0
var rising = true
var throw_counter = 0
var stun_counter = 0
var stunned = false
var grabbed = false
var grab_counter = 0
var throwing = true
var no_collisions = 0
var speed = 425
var outgoing_force = speed * 0.1
var lunge_counter = 0.0
var lunge_duration = 0.0
var lunging = false
var direction = Vector2.ZERO
var collision_counter = 0
var spacer = 0
var other_direction = Vector2.ZERO
var throw_dir = 0
var throw_vector = Vector2.ZERO
var speedin = 0
var degrees = 90
var arrow_deg = 0
var pantickset = 0.0
var throw_timer = 0.0
var puckvec = Vector2.ZERO

func _physics_process(delta):
	getpuckvec()
	
	if(!grabbed && !stunned):
		move_and_slide()
	
	if(!grabbed && grab_counter > 0):
		grab_counter -= 1
	
	if(throwing):
		no_collisions -= 1
		if(no_collisions <= 0):
			puck.set_collision_mask_value(6, true)
			set_collision_mask_value(3, true)
			throwing = false
			no_collisions = 0
	
	if(collision_counter > 0):
		collision_counter -= 1
		
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		if(collision.get_collider() is RigidBody2D && collision_counter == 0 && no_collisions <= 0):
			collision_counter = 50
			if(abs(puck.linear_velocity.length()) > abs(speed) && puck.linear_velocity.length() > 500 || velocity == Vector2.ZERO && puck.linear_velocity.length() >= 300):
				stunned = true
				stun_counter = 50
				puck.set_collision_mask_value(6, false)
				set_collision_mask_value(3, false)
				velocity = Vector2.ZERO
			else:
				if(lunging):
					collision.get_collider().apply_central_impulse(-collision.get_normal() * (outgoing_force * 3))
				else:
					collision.get_collider().apply_central_impulse(-collision.get_normal() * outgoing_force)
	
	if(stunned && stun_counter > 0):
		stun_counter -= 1
		if(stun_counter <= 0):
			stunned = false
			puck.set_collision_mask_value(6, true)
			set_collision_mask_value(3, true)
			
	if(grabbed):
		throw_timer -= delta
		$Arrow.rotation_degrees = arrow_deg
		throw_vector.x = cos(deg_to_rad(degrees))
		throw_vector.y = sin(deg_to_rad(degrees))
		throw_vector = throw_vector.normalized()
		$Arrow.position = throw_vector * 100
		direction_type = randi_range(4, 6)
		spacer -= 1
		degrees = randi_range(30, 150)
		print("GRABBED")
		probability = randi_range(1, 20)
		if(probability == 1):
			_throw()
		if(throw_timer <= 0.0):
			_throw()
				
		
	if(!puck.complete && puck.in_ai_range && !stunned && grab_counter == 0 && !Global.plant_grabbed):
		_grab()
				
	if(puck.complete && throw_counter >= 90):
		_throw()
			
			
func _grab():
		Global.ai_grabbed = true
		spacer = 3
		speedin = puck.linear_velocity.length()
		puck.complete = true
		print("grab!")
		puck.linear_velocity = Vector2.ZERO
		velocity = Vector2.ZERO
		grabbed = true
		throw_timer = 0.8
		degrees = -90
		arrow_deg = 0
		puck.freeze = true
		puck.scale.x = 0.5
		puck.scale.y = 0.5
		puck.global_position = global_position
		
func _throw():
	if(spacer <= 0):
		spacer = 0
		$Arrow.visible = false
		puck.complete = false
		grabbed = false
		puck.freeze = false
		grab_counter = 50
		throwing = true
		no_collisions = 50
		rising = true
		puck.set_collision_mask_value(6, false)
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
		Global.ai_grabbed = false
		
func setpantick():
	if(speedin > 2000):
		speedin = 2000
	if(speedin < 100):
		speedin = 100
	#normalize range
	var k = 0.0002
	pantickset = -1 + 11*(1-exp(-k*(speedin-100)))
	
func getpuckvec():
	puckvec = Vector2(450,45) + (puck.position - Vector2(450,45))/4
