extends Area2D

@onready var puck = get_tree().root.get_node("Node2D/Puck")

var direction = Vector2(0,1)
var speed = 600
var sucked = false
var timer = 0.0
var cooldown = 0.0

func _process(delta: float):
	if(cooldown > 0.0):
		cooldown -= delta
		if(cooldown <= 0.0):
			release_puck()
			
	if(sucked):
		timer -= delta
		puck.set_collision_mask_value(7, false)
		set_collision_mask_value(3, false)
		puck.collision_layer = 0
		puck.collision_mask = 0
		print("grab!")
		puck.linear_velocity = Vector2.ZERO
		puck.freeze_mode = RigidBody2D.FREEZE_MODE_STATIC
		puck.freeze = true
		puck.scale.x = 0.5
		puck.scale.y = 0.5
		puck.global_position = global_position
		if(timer <= 0.0):
			timer = 0.0
			sucked = false
			puck.freeze = false
			puck.scale.x = 1.0
			puck.scale.y = 1.0
			puck.linear_velocity = direction * speed
			cooldown = 0.1
			

func _on_body_exited(body):
	if(body is RigidBody2D && puck.linear_velocity.length() >= 500 && !sucked):
		get_parent().get_parent().queue_free()


func _on_body_entered(body):
	if(body is RigidBody2D):
		if(puck.linear_velocity.length() < 500 && !Global.ai_grabbed && !Global.plant_grabbed):
			Global.plant_grabbed = true
			sucked = true
			timer = 0.5
			
func release_puck():
	await get_tree().process_frame  # Wait until the next frame
	restore_puck_collision()
	
func restore_puck_collision():
	puck.collision_layer = 3
	puck.set_collision_layer_value(3, true)
	puck.set_collision_mask_value(1, true)
	puck.set_collision_mask_value(3, true)
	puck.set_collision_mask_value(4, true)
	puck.set_collision_mask_value(6, true)
	puck.set_collision_mask_value(7, true)
	Global.plant_grabbed = false
	get_parent().get_parent().queue_free()
	
