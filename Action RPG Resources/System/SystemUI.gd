extends CanvasLayer

#onready var _playerHealthUI = $PlayerHealthUI
#onready var _enemyHealthUI = $EnemyHealthUI
onready var _scoreBoard = $Score
onready var _countdown = $countdownTimer
onready var _first_countDown = $first_countDown

#func get_playerHealthUI():
#	return _playerHealthUI
	
#func get_enemyHealthUI():
#	return _enemyHealthUI

func get_ScoreBoard():
	return _scoreBoard

func start_game_timeLimit(_limit:int, _process):
	_countdown.timer_start(_limit, _process)
	display_timeLimitUI(true)

func start_first_countDown(_process):
	_first_countDown.timer_start(_process)
	display_countDownUI(true)
	pass

func display_scoreUI(_value:bool):
	_scoreBoard.visible = _value
	pass

#func display_player_healthUI(_value:bool):
#	_playerHealthUI.visible = _value
#	pass

#func display_enemy_healthUI(_value:bool):
#	_enemyHealthUI.visible = _value
#	pass
	
func display_timeLimitUI(_value:bool):
	_countdown.visible = _value
	pass

func display_countDownUI(_value:bool):
	_first_countDown.visible = _value
	pass

