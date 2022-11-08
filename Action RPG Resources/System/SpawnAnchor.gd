extends Node2D

#敵の種類をインスペクター上で変更できるように設定する。
export(String, FILE, ".*tscn") var instantiate_Enemy

#var born_pos = global_position

func _ready():
	$Sprite.visible = false
	pass

#var instantiate_Enemy = preload("res://Action RPG Resources/Enemies/Tear.tscn")

func enemy_Generate(gameManager, waveManager):
#	print("enemy spone!")
#	print(instantiate_Enemy)
	if instantiate_Enemy != "" :
		var enemy = load(instantiate_Enemy).instance()
	#	var enemy = instantiate_Enemy.instance()

	#	add_child(enemy)
		
	#	remove_child(enemy)
		
		gameManager.get_CharaList().call_deferred("add_child", enemy)
	#	get_node("%CharaList").add_child(enemy)
		
		
		enemy.set_global_position(self.position + get_parent().get_parent().global_position - gameManager.global_position)
		print("anchor pos : " + str(self.global_position))
		print("spawn enemy pos : " + str(enemy.position))
#		enemy.position = (get_parent().global_position)

	#	enemy.global_position = global_position
		
		enemy.set_WaveEnemy()
	#	waveManager.set_destroy_Wave_Enemy_Connect(enemy)
		waveManager.set_death_Wave_Enemy_Connect(enemy)
		pass
	
#var enemyDeathEffect = EnemyDeathEffect.instance()
#	get_parent().add_child(enemyDeathEffect)
#	enemyDeathEffect.global_position = global_position
