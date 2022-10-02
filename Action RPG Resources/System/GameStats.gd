extends Node2D

signal change_Score_UI(value)

enum CharaType{
	PLAYER,
	ENEMY,
	OBJECT
}

var gameScore = 0 setget set_Score, get_Score

func set_Score(value):
	gameScore = min(gameScore + value, 100000)
	emit_signal("change_Score_UI", gameScore)
	print("score : " + str(gameScore))
	pass
	
func get_Score():
	return gameScore
	pass

func reset_Score():
	gameScore = 0
