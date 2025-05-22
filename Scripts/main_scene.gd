extends Node3D

@onready var pause_menu = $PauseMenu

func _input(event):
	if event is InputEventKey and event.keycode == KEY_ESCAPE and event.pressed:
		pause_menu.toggle_menu() 