extends Node2D

var scene_to_switch = ""

func scene_change(scene: String):
	scene_to_switch = scene
	$AnimationPlayer.play("FadeIn")
	get_tree().change_scene(scene)

