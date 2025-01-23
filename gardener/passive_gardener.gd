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

func _ready():
	if Ai == null:
		Ai = get_parent().get_parent()
		
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
		var plant = StaticBody2D.new()
		var plant_shape = CollisionShape2D.new()
		var plant_sprite = Sprite2D.new()
		var circle_shape = CircleShape2D.new()
		circle_shape.radius = 50 
		plant_shape.shape = circle_shape
		plant.add_child(plant_shape)
		plant.add_child(plant_sprite)
		plant_sprite.texture = preload("res://sprites/icon.svg")
		plant.physics_material_override = PhysicsMaterial
		#plant_sprite.scale.x = 3/4
		#plant_sprite.scale.y = 3/4
		plant.set_collision_layer_value(7, true)
		plant.set_collision_mask(1 << 3) 
		plant.position = Ai.position  # Set its position
		node.add_child(plant)
		randomize_garden()
		
		#area.body_entered.connect(_on_body_entered.bind(area))
		
	if(wandering_time > 0):
		wandering_time -= delta
	else:
		randomize_wander()

#func _on_body_entered(body):
#	if body is RigidBody2D:
#		queue_free()

func Physics_Update(delta: float):
	
	Ai.velocity  = move_direction * move_speed
	
	if (puck.linear_velocity.y < 0 && puck.global_position.y < 600):
		Transitioned.emit(self, "active_gardener")
