extends Node2D

export(Array, Resource) var load_waveList
export(String, FILE, "*.tscn") var gameoverScene
export(String, FILE, "*.tscn") var resultScene

onready var charaList = $CharaList

onready var timeout_effect = $timeout_effect

onready var bgm = $BGM

#読み込んだload_waveSetに含まれるwaveの数をカウントする
var now_Wave  = 0
var waveMaxNum = 0

#-------playerのステータス---------
#死亡時演出の呼び出しなどに使用
#var stats = PlayerStats
#--------------------------------

func start_countDown():
	SystemUi.visible = true
	SystemUi.start_first_countDown(self)
	bgm.play()
	pass
	
func settingGameManager():
	
	#----PlayerのHP=0の時、死亡演出の起動---------
#	stats.connect("no_health", self, "player_dead")
	#------------------------------------------
	
	#----charaList内で初期化---------
	charaList.setting()
	#------------------------------------------
	
	#countdownのリセット、開始
	SystemUi.start_game_countDown(20, self)
	
	#-------wave準備系----------
	waveMaxNum = load_waveList.size()
#	print("waveMaxNum : " + str(waveMaxNum))
	nextWave()
	#----------------------------
	
#WaveManagerで、wave内の全ての敵が倒された時に送られる信号で実行される関数
func nextWave():
	if(now_Wave < waveMaxNum):
		load_WaveScene(load_waveList[now_Wave])
		now_Wave += 1
	else:
		print("next wave finish")
#		game_finished()
		now_Wave = 0
		nextWave()
	
func load_WaveScene(load_wave):
#	print("wave!")
	var wave = load_wave.instance()
	wave.connect("wave_Finish", self, "nextWave")
	wave.connect_GameManager(self)
	add_child(wave)
	
func get_CharaList():
	return charaList
	
func player_dead():
	SystemUi.visible = false
	get_tree().change_scene(gameoverScene)
	pass

func time_out():
	game_finished()
	pass
	
func _on_timeout_effect_timeout():
	SystemUi.visible = false
	game_finished()
	pass # Replace with function body.

func game_finished():
	bgm.stop()
	SystemUi.visible = false
	get_tree().change_scene(resultScene)
	pass
