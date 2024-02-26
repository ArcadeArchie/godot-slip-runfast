extends Button

onready var mainMenu = get_node("/root/")

func _on_settings_button_up():
	get_tree().change_scene("res://src/scenes/settings.tscn")
