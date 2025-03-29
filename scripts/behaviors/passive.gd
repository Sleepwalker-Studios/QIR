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
	var bar = 10
	Ai.direction = Ai.puckvec - Ai.global_position
	if(Ai.direction.length() < 5):
		Ai.velocity = Ai.velocity.lerp(Vector2.ZERO, 0.2)
	elif(puck.linear_velocity.length() <= bar && !char.grabbed):
		Ai.velocity = Ai.velocity.lerp(Vector2.ZERO, 0.2)
	else:
		Ai.velocity = Ai.velocity.lerp(Ai.direction.normalized() * Ai.speed, 0.1)
	
	if (puck.linear_velocity.y < 0 || puck.linear_velocity.y > 0 && puck.global_position.y < 600):
		Transitioned.emit(self, "active")
