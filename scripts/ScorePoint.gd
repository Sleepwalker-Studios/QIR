extends RigidBody2D
var stagnant = false
var complete = false
var pos_save = null
var in_range = false
var in_ai_range = false
@onready var timer: Timer = $Timer
@onready var timeout = $Timeout

@onready var character = get_parent().get_node("Character")
@onready var control = get_parent().get_node("Control")
@onready var puck = get_parent().get_node("Puck")
@onready var casper2 = get_parent().get_node("Area2D")
@onready var casper3 = get_parent().get_node("Area2D2")

func _on_grab_area_body_entered(body: Node2D) -> void:
	if(body.name.begins_with("Puck")):
		print("in range")
		in_range = true
		
func _on_grab_area_body_exited(body: Node2D) -> void:
	if(body.name.begins_with("Puck")):
		print("out range")
		in_range = false
		
func _on_grab_area_ai_body_entered(body: Node2D) -> void:
	if(body.name.begins_with("Puck")):
		print("in range")
		in_ai_range = true
		
func _on_grab_area_ai_body_exited(body: Node2D) -> void:
	if(body.name.begins_with("Puck")):
		print("out range")
		in_ai_range = false
		
func _on_area_2d_body_entered(body: Node2D) -> void:
	if(body.name.begins_with("Puck")):
		print("P1 Scored")
		Global.user_score += 1
		control._update_user_score()
		if(Global.user_score >= 7):
			Global.user_score = 0
			Global.bot_score = 0
			Global.bottom_player_win = true
			for child in get_parent().get_children():
				child.queue_free()
			get_tree().change_scene_to_file("res://scenes/WinScreen.tscn")
		else:
			timer.start()


func _on_area_2d_2_body_entered(body: Node2D) -> void:
	if(body.name.begins_with("Puck")):
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
		

func _on_timer_timeout() -> void:
	get_tree().reload_current_scene()
