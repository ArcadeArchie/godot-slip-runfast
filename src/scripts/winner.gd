extends Control


func _ready():
	$background/info.text = $background/info.text % [str(player_data.minutes), 
													str(player_data.seconds)]
	
