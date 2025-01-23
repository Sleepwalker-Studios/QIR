extends Control

@onready var local: Button = $MarginContainer/VBoxContainer/Local

func _ready() -> void:
	local.grab_focus()

func _on_local_pressed() -> void:
	pass


func _on_tournament_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Rounds.tscn")


func _on_practice_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Base.tscn")


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
