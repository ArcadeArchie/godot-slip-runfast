extends Control


var paused = false setget set_paused


func _unhandled_input(event):
	if event.is_action_pressed("pause"):
		self.paused = not self.paused
		get_tree().set_input_as_handled()



func set_paused(value):
	paused = value
	get_tree().paused = value
	$pause_overlay.visible = value
