extends Node


signal player_winner


var winner:= 0 setget set_winner

var minutes:= 0 setget set_minutes
var seconds:= 0 setget set_seconds


func reset():
	winner = 0
	
func set_winner(state):
	winner = state
	emit_signal("player_winner")


func set_minutes(value):
	minutes = value
	
	
func set_seconds(value):
	seconds = value
