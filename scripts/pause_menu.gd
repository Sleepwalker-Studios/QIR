extends Control

@onready var control = $"../"
@onready var resume: Button = $MarginContainer/VBoxContainer/Resume

func _ready() -> void:
	resume.grab_focus()

func _on_resume_pressed() -> void:
	control.pauseMenu()

func _on_quit_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Modes.tscn")
