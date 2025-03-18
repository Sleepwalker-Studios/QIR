#when y velocity is positive on the bottom half of the arena (player side)
#positions to center/guard

extends State
class_name passive
@export var Ai: CharacterBody2D
@onready var char = get_parent().get_parent().get_parent().get_node("Character")
@onready var puck = get_parent().get_parent().get_parent().get_node("Puck")
@onready var casper = get_parent().get_parent().get_parent().get_node("casper")

func _ready():
	if Ai == null:
		Ai = get_parent().get_parent()

func Physics_Update(delta: float):
	Ai.direction = Ai.puckvec - Ai.global_position
	Ai.direction = Ai.direction.move_toward(Ai.direction, delta * 5.0)
	var bar = 10
	if(Ai.global_position == Ai.puckvec):
		Ai.velocity = Vector2.ZERO
	elif(puck.linear_velocity.length() <= bar && !char.grabbed):
		Ai.velocity = Vector2.ZERO
	else:
		Ai.velocity  = Ai.direction.normalized() * Ai.speed
	
	if (puck.linear_velocity.y < 0 || puck.linear_velocity.y > 0 && puck.global_position.y < 600):
		Transitioned.emit(self, "active")
