extends State_gardener
class_name passive_gardener
@export var plant: PackedScene
@onready var node = get_parent().get_parent().get_parent()
@onready var Ai = get_parent().get_parent()
@onready var puck = get_parent().get_parent().get_parent().get_node("Puck")
@onready var casper = get_parent().get_parent().get_parent().get_node("casper")
var wandering_time
var time = 0.0
var ctime = 0.0
var move_direction
var create = false
var plantcount = 0
var move_speed = 150
var plantpos = Vector2.ZERO
var garden_time
var scene = preload("res://scenes/plant.tscn")
var reference: Array = []
var pts: Array = [Vector2(325, 200), Vector2(200, 350), Vector2(325, 500), Vector2(575, 200), Vector2(700, 350), Vector2(575, 500)]
var state = 1

func _ready():
	if Ai == null:
		Ai = get_parent().get_parent()
	create_plant(Vector2(randi_range(175, 225), randi_range(200, 250)))
	create_plant(Vector2(randi_range(425, 475), randi_range(225, 275)))
	create_plant(Vector2(randi_range(675, 725), randi_range(200, 250)))
		
func randomize_wander():
	
	match state:
		1: move_direction = (pts[0] - Ai.position).normalized()
		2: move_direction = (pts[1] - Ai.position).normalized()
		3: move_direction = (pts[2] - Ai.position).normalized()
		4: move_direction = (pts[3] - Ai.position).normalized()
		5: move_direction = (pts[4] - Ai.position).normalized()
		6: move_direction = (pts[5] - Ai.position).normalized()
	
func randomize_garden():
	garden_time = randi_range(1, 3)
		
func Enter():
	print("bruh")
	randomize_wander()
	randomize_garden()

func Update(delta: float):
	if(create):
		ctime -= delta
		if(ctime <= 0.0):
			create_plant(plantpos)
			ctime = 0.0
			create = false
	if(garden_time > 0):
		garden_time -= delta

	else:
		if(Ai.grabbed == false):
			plantpos = Ai.position + Vector2(randi_range(-80, 80), randi_range(-80, 80))
			if(plantpos.x < 765 && plantpos.x > 135 && plantpos.x < 565 && plantpos.y > 85):
				create = true
				ctime = 1.0
		garden_time = 3
	if(time > 0.0):
		time -= delta
	else:
		time = 0.0
	
	for i in range(6):
		if(time <= 0.0):
			if (Ai.position - pts[i]).length() < 10:
				if(state < 6):
					state += 1
				else:
					state = 1
				time = 1
	randomize_wander()


#func _on_body_entered(body):
#	if body is RigidBody2D:
#		queue_free()

func clear_plants():
	for instance in reference:
		if is_instance_valid(instance):
			instance.queue_free()
	reference.clear()
	plantcount = 0

func create_plant(position: Vector2):
	if(plantcount < 7):
		var instance = scene.instantiate()
		get_tree().root.add_child(instance)
		instance.position = position
		reference.append(instance)
		plantcount += 1
	

func Physics_Update(delta: float):
	
	if(!Ai.grabbed):
		Ai.velocity  = move_direction * move_speed
	else:
		Ai.velocity = Vector2.ZERO
	
#	if (puck.linear_velocity.y < 0 && puck.global_position.y < 600):
#		Transitioned.emit(self, "active_gardener")
