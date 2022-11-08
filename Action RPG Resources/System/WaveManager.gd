extends Node2D

#waveの敵が全て倒された時にGameManagerに次のwaveの開始信号を送る
signal wave_Finish

#wave上の敵のカウント
var wave_enemy_count = 0

#signalを削除する用に保存しておく
#var spawner

func connect_GameManager(gameManager):
#	gameManager.connect("wave_Finish", gameManager, "nextWave")
#	spawner = spawner
	#生成する敵の数を取得
	for waveEnemy in get_children():
		if waveEnemy.name.find("SpawnAnchor") != -1:
			wave_enemy_count += 1
			waveEnemy.enemy_Generate(gameManager, self)
	
	print("enemy : " + str(wave_enemy_count))
	
func set_death_Wave_Enemy_Connect(enemy):
	enemy.connect("death", self, "death_Wave_Enemy")
	pass

func death_Wave_Enemy(enemy):
	wave_enemy_count -= 1
	enemy.disconnect("death", self, "death_Wave_Enemy")
	enemy.queue_free()
	
	if(wave_enemy_count <= 0):
		emit_signal("wave_Finish")
#		self.disconnect("wave_Finish", spawner, "nextWave")
#		GameManager.nextWave()
		print("wave end!")
		queue_free()
