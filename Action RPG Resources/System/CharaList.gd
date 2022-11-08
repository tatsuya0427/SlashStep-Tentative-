extends YSort

onready var player = get_node("%Player")
onready var duelSystem = get_node("%DuelSystem")
onready var player_duelPos = get_node("%Player_Pos")
onready var enemy_duelPos = get_node("%Enemy_Pos")
onready var player_camera = get_node("%Camera2D")
onready var lowLight = get_node("%lowLight")

#playerが参照するために移動先の座標を保存しておく
var player_duelPos_save:= Vector2.ZERO
#enemyが参照するために移動先の座標を保存しておく
var enemy_duelPos_save:= Vector2.ZERO

#ターゲットを決める際に最有力候補のクラスを保存しておく変数
var targetChara = null

#ターゲット候補をlistとして格納しておく
var targetCharaList = []

#duelシステム起動時の相手クラス
var duel_target = null

#stepHightTileを保存しておく変数
var stepHightTile

onready var map_rect



func _ready():
	lowLight.visible = false
	
	#WorldManagerのstepHightTileを取得する
	stepHightTile = get_parent().get_parent().find_node("stepHightTile")
	
	var map_limits = stepHightTile.get_used_rect()
	print("map_limits", map_limits)
	var map_cell_size = stepHightTile.cell_size
	print("map_cell_size", map_cell_size)
	print("position start : " + str(stepHightTile.get_used_rect().position.x * stepHightTile.cell_size.x))
	print(stepHightTile.get_used_rect().position.x * stepHightTile.cell_size.x + stepHightTile.position.x)
	print("position end   : " + str(stepHightTile.get_used_rect().end.x * stepHightTile.cell_size.x))
	print(stepHightTile.get_used_rect().end.x * stepHightTile.cell_size.x + stepHightTile.position.x)

	player_camera.limit_left = stepHightTile.get_used_rect().position.x * stepHightTile.cell_size.x + stepHightTile.position.x
	player_camera.limit_right = stepHightTile.get_used_rect().end.x * stepHightTile.cell_size.x + stepHightTile.position.x
	player_camera.limit_bottom = stepHightTile.get_used_rect().end.y * stepHightTile.cell_size.y + stepHightTile.position.y
	player_camera.limit_top = stepHightTile.get_used_rect().position.y * stepHightTile.cell_size.y + stepHightTile.position.y
	
#	player_camera.limit_left = -10000000
#	player_camera.limit_right = 10000000
#	player_camera.limit_bottom = 10000000
#	player_camera.limit_top = -10000000
	
	
	player_camera.limit_smoothed = true
	

#初期化設定
func setting():
#	ex_anim
	player.setting()
	pass

func get_gameManager():
	print(get_parent())
	return get_parent()

func add_Chara(chara):
	add_child(chara)

#playerから見て一番近い敵を取得する
func get_ClosestTarget_fromPlayer():
	var min_distance = 0
	var targetEnemy = null
	
	for target in get_children():
		if target.get_child_count() > 0:
			var targetStats = target.find_node("Stats")
#			print(targetStats)
			if targetStats != null && targetStats.myType == GameStats.CharaType.ENEMY:
				if target.live:
					target.set_targeting(false)
					targetCharaList.append(target)
					
					var distance = 0
					var pos_vector = (target.global_position - player.global_position)
	#				distance += (pos_vector.x / sqrt(pow(pos_vector.x, 2) + pow(pos_vector.y, 2))) + (pos_vector.y / sqrt(pow(pos_vector.x, 2) + pow(pos_vector.y, 2)))
					distance = pow(pos_vector.x, 2) + pow(pos_vector.y, 2)
	#				distance = abs(distance)
	#				distance = abs(pos_vector.x) + abs(pos_vector.y)
	#				targetChara.pop.text = str(distance)
					if(min_distance == 0):
						min_distance = distance
						targetEnemy = target
					
					if min_distance > distance:
	#					print("-----")
						min_distance = distance
	#					print("decision :" + str(min_distance))
						targetEnemy = target

#	if(targetEnemy != null && min_distance < 2.0):
	if(targetEnemy != null):
		if !player.now_duelSystem:
#		if !player.now_duelSystem && targetEnemy != targetChara:
			targetEnemy.set_targeting(true)
			targetChara = targetEnemy
		
#		for otherEnemy in targetCharaList:
#			if otherEnemy != targetChara:
#				targetEnemy.set_targeting(false)
		
	else:
		targetChara = null
#		print("too long!")


func death_targetEnemy():
	targetChara = null
	get_ClosestTarget_fromPlayer()
	pass
	
func target_reset():
	for targetChara in get_children():
		if targetChara.get_child_count() > 0:
			var targetStats = targetChara.find_node("Stats")
			if targetStats != null && targetStats.myType == Stats.CharaType.ENEMY:
				targetChara.set_targeting(false)

func start_EXAttack(value:String):
	#valueで使用する技を選択する
	for targetChara in get_children():
		var have_Stats = null
		if targetChara.get_child_count() > 0:
			have_Stats = targetChara.find_node("Stats")
		if have_Stats != null:
			match have_Stats.myType:
				GameStats.CharaType.ENEMY:
					targetChara.ex_attack_start()
				GameStats.CharaType.PLAYER:
					targetChara.start_ex_attack(self, player_camera.get_camera_position())
	
	print("hogehoge")

func end_EXAttack():
	for targetChara in get_children():
		var have_Stats = null
		if targetChara.get_child_count() > 0:
			have_Stats = targetChara.find_node("Stats")
		if have_Stats != null:
			match have_Stats.myType:
				GameStats.CharaType.ENEMY:
					targetChara.ex_attack_end()
				GameStats.CharaType.PLAYER:
					targetChara.stateMatchine.ChangeState(player.moveState)
	

func start_duelSystem(targetEnemy):
#	print(targetEnemy)
#	print(targetEnemy == player.target_enemy)
	
	if targetEnemy != null && targetEnemy.can_duelFlag:
		player_camera.current = false
		
		duel_target = targetEnemy
		player.connect("duel_damage", duel_target, "duel_attack_endAnimation")
		
		player_duelPos_save = player_duelPos.global_position
		enemy_duelPos_save = enemy_duelPos.global_position
		
		player.move_duelStage(player_duelPos.global_position - self.global_position)
		player.z_index = lowLight.z_index + 1
		
		targetEnemy.move_duelStage(enemy_duelPos.global_position - self.global_position)
		targetEnemy.z_index = lowLight.z_index + 1
		
		for targetChara in get_children():
			var have_Stats = null
			if targetChara.get_child_count() > 0:
				have_Stats = targetChara.find_node("Stats")
			if targetChara != player && have_Stats != null:
#			if targetChara != player && targetChara != lowLight && targetChara != duelSystem:
#				print(targetChara.will_attack_class)
				
				#duelシステム起動時に対象でないキャラクターはfalse、対象のキャラクターはtrueで関数を実行
				if targetChara != targetEnemy:
					#対象外のEnemyをDualStayStateに変更
					targetChara.execution_DuelAttack(false)
#				targetChara.stateMatchine.ChangeState(targetChara.will_attack_class.get_duelAttack())
				else :
					#EnemyのstateをDualStateに変更
					targetChara.execution_DuelAttack(true)

#		target_reset()
		lowLight.visible = true
	
func end_duelSystem():
	print("end duel")
	#player内のデュアルシステム解除関数を起動
	#EnemyのstateをIDLEStateに変更
	#対象外のEnemyを変更前のStateに変更
	for targetChara in get_children():
		if targetChara == player:
#			print("end duel player")
			player.now_duelSystem = false
			player.stateMatchine.ChangeState(player.moveState)
			player_camera.current = true
			player.disconnect("duel_damage", duel_target, "duel_attack_endAnimation")
		elif targetChara == lowLight:
#			print("end duel lowLight")
			lowLight.visible = false
		elif targetChara != duelSystem && targetChara.find_node("Stats") != null:
#			print("end duel enemy")
			targetChara.end_DuelAttack()
	pass

func frameFreeze(timeScale, duration):
	Engine.time_scale = timeScale
	yield(get_tree().create_timer(duration * timeScale), "timeout")
	Engine.time_scale = 1.0

func duelEnd_frameFreeze(timeScale, duration):
	if player.now_duelSystem :
		Engine.time_scale = timeScale
		yield(get_tree().create_timer(duration * timeScale), "timeout")
		Engine.time_scale = 1.0
		end_duelSystem()
	else:
		print("ERROR：player now_duelSystem is not true")
	pass

func _process(delta):
	duelSystem.global_position = player_camera.get_camera_position()

	if Input.is_action_just_pressed("jump"):
#		self.paused = true
		self.pause_mode = Node.PAUSE_MODE_STOP
		pass
