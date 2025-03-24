extends State_gardener
class_name passive_gardener
@export var plant: PackedScene
@onready var node = get_parent().get_parent().get_parent()
@onready var Ai = get_parent().get_parent()
@onready var puck = get_parent().get_parent().get_parent().get_node("Puck")
@onready var casper = get_parent().get_parent().get_parent().get_node("casper")
var wandering_time
var move_direction
var move_speed = 200
var garden_time
var scene = preload("res://scenes/plant.tscn")
var reference: Array = []

func _ready():
	if Ai == null:
		Ai = get_parent().get_parent()
	create_plant(Vector2(200, 225))
	create_plant(Vector2(450, 250))
	create_plant(Vector2(700, 225))
		
func randomize_wander():
	move_direction = Vector2(randi_range(-1, 1), randi_range(-1, 1)).normalized()
	wandering_time = randi_range(1, 3)
	
func randomize_garden():
	garden_time = randi_range(1, 3)
		
func Enter():
	print("bruh")
	randomize_wander()
	randomize_garden()

func Update(delta: float):
	if(garden_time > 0):
		garden_time -= delta

	else:
		create_plant(Ai.position)
		garden_time = 3
		
	if(wandering_time > 0):
		wandering_time -= delta
	else:
		randomize_wander()

#func _on_body_entered(body):
#	if body is RigidBody2D:
#		queue_free()

func clear_plants():
	for instance in reference:
		if is_instance_valid(instance):
			instance.queue_free()
	reference.clear()

func create_plant(position: Vector2):
	var instance = scene.instantiate()
	get_tree().root.add_child(instance)
	instance.position = position
	reference.append(instance)
	

func Physics_Update(delta: float):
	
	Ai.velocity  = move_direction * move_speed
	
#	if (puck.linear_velocity.y < 0 && puck.global_position.y < 600):
#		Transitioned.emit(self, "active_gardener")
