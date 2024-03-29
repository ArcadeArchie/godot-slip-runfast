extends Node2D

onready var mainMenu = get_node("../main")


onready var music_slider = $"MusicSlider"
onready var sfx_slider = $"SFXSlider"


onready var music_bus = AudioServer.get_bus_index("Music")
onready var sfx_bus = AudioServer.get_bus_index("SFX")


func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


const max_db = 0
const min_db = -40



func _on_MusicSlider_drag_ended(value_changed):
	if value_changed:
		# if value =0, then min_db, if 100, then max_db
		var new_volume = lerp(min_db, max_db, float(music_slider.value)/100.0)
		AudioServer.set_bus_volume_db(music_bus, new_volume)


func _on_SFXSlider_drag_ended(value_changed):
	if value_changed:
		# if value =0, then min_db, if 100, then max_db
		var new_volume = lerp(min_db, max_db, float(sfx_slider.value)/100.0)
		AudioServer.set_bus_volume_db(sfx_bus, new_volume)


func _on_BackButton_pressed():
	mainMenu.show()