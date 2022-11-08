extends Node2D

export(Array, Resource) var _load_waveList
var _gameManager

#読み込んだload_waveSetに含まれるwaveの数をカウントする
var _now_Wave  = 0
var _waveMaxNum = 0

func wave_start(gameManager):
	_gameManager = gameManager
	_waveMaxNum = _load_waveList.size()
	print("max wave num : " + str(_waveMaxNum))
	nextWave()

#WaveManagerで、wave内の全ての敵が倒された時に送られる信号で実行される関数
func nextWave():
	if(_now_Wave < _waveMaxNum):
		print("now wave : " + str(_now_Wave))
		load_WaveScene(_load_waveList[_now_Wave])
		_now_Wave += 1
	else:
		print("next wave finish")
#		game_finished()
		_now_Wave = 0
		nextWave()
	
func load_WaveScene(load_wave):
#	print("wave!")
	var wave = load_wave.instance()
	add_child(wave)
	wave.global_position = self.global_position
	wave.connect("wave_Finish", self, "nextWave")
	print(self)
	wave.connect_GameManager(_gameManager)
