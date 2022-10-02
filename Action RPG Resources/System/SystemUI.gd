extends CanvasLayer

onready var playerHealthUI = $PlayerHealthUI
onready var enemyHealthUI = $EnemyHealthUI
onready var ScoreBoard = $Score
onready var countdown = $countdownTimer
onready var first_countDown = $first_countDown

func get_playerHealthUI():
	return playerHealthUI
	
func get_enemyHealthUI():
	return enemyHealthUI

func get_ScoreBoard():
	return ScoreBoard

func start_game_countDown(limit:int, process):
	countdown.timer_start(limit, process)

func start_first_countDown(process):
	first_countDown.timer_start(process)
	pass
