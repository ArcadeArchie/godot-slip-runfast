extends Control


func _ready():
	$AnimatedSprite.play()
	$music.play()


func _on_timer_start_game():
	$start_game.visible = !$start_game.visible
