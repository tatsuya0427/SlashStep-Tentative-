extends Node2D

export(Array, Resource) var _load_waveList
export(String, FILE, "*.tscn") var _gameoverScene
export(String, FILE, "*.tscn") var _resultScene
export var _game_time_limit = 60
export var _use_countdown : bool = true
export var _use_timeLimit : bool = true

onready var _charaList = $CharaList

onready var _timeout_effect = $timeout_effect

onready var _bgm = $BGM
export  var _use_bgm : bool = false

#spone関係の変数

#読み込んだload_waveSetに含まれるwaveの数をカウントする
var _now_Wave  = 0
var _waveMaxNum = 0

#-------playerのステータス---------
#死亡時演出の呼び出しなどに使用
#var stats = PlayerStats
#--------------------------------

func start_countDown():
	SystemUi.visible = true
	if _use_countdown:
		SystemUi.start_first_countDown(self)
	else:
		settingGameManager()
	
	if _use_bgm:
		_bgm.play()
	pass
	
func settingGameManager():
	
	#----PlayerのHP=0の時、死亡演出の起動---------
#	stats.connect("no_health", self, "player_dead")
	#------------------------------------------
	
	#----charaList内で初期化---------
	_charaList.setting()
	#------------------------------------------
	
	#countdownのリセット、開始
	
	if _use_timeLimit:
		SystemUi.start_game_timeLimit(_game_time_limit, self)
	
#	SystemUi.display_enemy_healthUI(true)
#	SystemUi.display_player_healthUI(true)
	SystemUi.display_scoreUI(true)
	
	#-------wave準備系----------
#	_waveMaxNum = _load_waveList.size()
#	print("waveMaxNum : " + str(waveMaxNum))
#	nextWave()
	#var _sponeManager = load("res://Action RPG Resources/System/Spawner.tscn")
#	add_child(_sponeManager)
#	_sponeManager.wave_start()
#	_sponeManager.wave_start()
	#----------------------------
	
func on_spawnArea(_spawner):
	print(_spawner)
	_spawner.wave_start(self)
	pass
	
#WaveManagerで、wave内の全ての敵が倒された時に送られる信号で実行される関数
#func nextWave():
#	if(_now_Wave < _waveMaxNum):
#		load_WaveScene(_load_waveList[_now_Wave])
#		_now_Wave += 1
#	else:
#		print("next wave finish")
##		game_finished()
#		_now_Wave = 0
#		nextWave()
#
#func load_WaveScene(load_wave):
##	print("wave!")
#	var wave = load_wave.instance()
#	wave.connect("wave_Finish", self, "nextWave")
#	wave.connect_GameManager(self)
#	add_child(wave)
	
func get_CharaList():
	return _charaList
	
func player_dead():
	SystemUi.visible = false
	get_tree().change_scene(_gameoverScene)
	pass

func time_out():
	game_finished()
	pass
	
func _on_timeout_effect_timeout():
	SystemUi.visible = false
	game_finished()
	pass # Replace with function body.

func game_finished():
	_bgm.stop()
	SystemUi.visible = false
	get_tree().change_scene(_resultScene)
	pass
