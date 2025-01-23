extends State_gardener
class_name active_gardener
@export var Ai: CharacterBody2D
@onready var puck = get_parent().get_parent().get_parent().get_node("Puck")
@onready var character = get_parent().get_parent().get_parent().get_node("Character")
var move_direction
var move_speed = 300

func _ready():
	if Ai == null:
		Ai = get_parent().get_parent()

func Physics_Update(delta: float):
	move_direction = puck.global_position - Ai.global_position
	
	Ai.velocity  = move_direction.normalized() * -Ai.speed
	
	if (puck.linear_velocity.y > 0 || puck.global_position.y >= 600 || character.grabbed):
		Transitioned.emit(self, "passive_gardener")

	
		
