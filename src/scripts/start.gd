extends Control


func _ready():
	$music.play()


func _on_settings_pressed():
	get_tree().change_scene("res://src/scenes/settings.tscn")