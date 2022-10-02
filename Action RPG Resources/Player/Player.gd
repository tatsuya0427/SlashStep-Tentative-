extends KinematicBody2D

enum player_state{
	MOVE,
	ROLL,
	ATTACK1,
	ATTACK2,
	ATTACK3,
	JUMPATTACK,
	DUEL
}

#var state = player_state.MOVE
#var runVector = run_vec.RIGHT

var velocity = Vector2.ZERO
var roll_vector = Vector2.DOWN

#playerが右を向いているかどうか
var is_look_right = true

var input_vector

var delta_scope

#攻撃中に追加でattackボタンを押した際に、この変数がtrueなら次のコンボ攻撃になる
var canNextCombo = false

#状態遷移を司るステートマシン
onready var stateMatchine = StateMatchine.new(self)

#各状態のステート内容を格納する変数
onready var moveState = PlayerIdleState.new()
onready var attack1State = PlayerAttack1State.new()
onready var attack2State = PlayerAttack2State.new()
onready var attack3State = PlayerAttack3State.new()
onready var rollState = PlayerRollState.new()
onready var damageState = PlayerDamageState.new()
onready var duelState = PlayerDuelState.new()

onready var exAttackState = PlayerEXAttackState.new()



#---------stats 関連------------
#var stats = PlayerStats
onready var stats = $Stats
export (int) var ACCELERATION = 300
export (int) var MAX_SPEED = 80
export (int) var ROLL_SPEED = 120
export (int) var FRICTION

#settingが起動したら移動できるようになる。
var can_move = false
#---------------------

#---------SE 関連------------
onready var attackSE = $AttackSE
onready var attackSE2 = $AttackSE2
onready var attackSE3 = $AttackSE3
onready var duel_attackSE = $Duel_AttackSE
#---------------------

#-----------animation関係--------------
#_ready()と同じタイミングで実行してくれる変数
onready var animationPlayer = $AnimationPlayer
#$を使うことで、子ノードの機能のパスを入れることができる。
#onready var animationTree = $AnimationTree
#onready var animationState = animationTree.get("parameters/playback")

#デュエルシステム起動時の移動をこれで行う。
#onready var tween = get_tree().create_tween()
#onready var tween = $Tween

#---------------------------------------

#--------------攻撃当たり判定関係----------------
onready var swordHitbox = $HitboxPivot/SwordHitbox
onready var swordHitbox_collision = $HitboxPivot/SwordHitbox/CollisionShape2D


#攻撃時のノックバック方向とその強さを保存
var knockback_vector
var knockback_pow
#---------------------------------------

#-------------当たり判定関係--------------------------
onready var k_body = self
onready var hurtbox = $HurtBox
onready var hurtboxCollision = $HurtBox/CollisionShape2D
onready var knockback = Vector2.ZERO

onready var invincibleTimer = $InvincibleTime
#---------------------------------------

#-------攻撃時に近い敵に追尾するようにする機能--------
onready var charaList = get_parent()
onready var enemyDetrctionZone = $EnemyDetectionZone
var target_enemy = null
var target_enemy_pos = null
var attack_vector = Vector2.ZERO
var initial_attack_vector = Vector2.RIGHT
#攻撃時に移動する移動量
export var STEP_SPEED = 10
#敵をターゲットした時の移動量(倍数)
export var findEnemyStep = 2
#-----------------------------------------------


#-------------duelSysTem関連---------------------
#現在、duelSystemが起動しているかどうか
var now_duelSystem = false

#duelSystem中で、カウンターや回避行動中は、他の行動ができないように制御する
var now_duelAction = false

signal duel_damage

#var EXGage
#-----------------------------------------------

#-------------gameSysTem関連---------------------
#var gameManager = null
#-----------------------------------------------


#---------z軸ジャンプ変数------------
#export (int) var shadow_offset
#export (int) var body_offset

#var z            = 0           # 最終的にY座標に足し引きする値、Z座標（高さ） 
#var z_floor      = 0           # Z座標の０地点（地面の高さ） 
#var z_speed      = 4           # ジャンプ上昇時の勢い
#var z_grav       = 0           # ジャンプ下降時の勢い 
#var grav_rate    = 0.25        # ジャンプ下降時の勢いに加算する値
#var jump         = false       # ジャンプ状態かどうか判定するbool値

#signal inStep (hight)
#signal outStep(height)

#signal collided

onready var icon = $PlayerIcon


# 最終的にY座標に足し引きする値、Z座標（高さ） 
var z            = 0
# Z座標の０地点（地面の高さ） 
var z_floor      = 0

#var is_floot = false

#ジャンプの頂点
export var jump_height : float
#二次関数の頂点までの起動
export var jump_time_to_peak : float
#二次関数の頂点から下まで
export var jump_time_to_descent : float

#ジャンプ速度
onready var jump_velocity : float = ((2.0 * jump_height) / jump_time_to_peak) * -1.0
#ジャンプ重力
onready var jump_gravity : float = ((-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)) * -1.0
#落下重力
onready var fall_gravity : float = ((-2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent)) * -1.0
#---------------------

func hogehoge():
	print("hogehoge")

func get_gravity() -> float:
	return jump_gravity if z < 0.0 else fall_gravity
#	return jump_gravity if velocity.y < get_parent().player_duelPos.y else fall_gravity

func jump():
	z = jump_velocity
	#----------------------------------
	# 影の位置を調整
#	$Shadow.global_position.y = global_position.y + 10 - z_floor
#	$Z_Area.global_position.y = global_position.y + 10 - z_floor
#	$Shadow.global_position.y = global_position.y - z_floor
#	$Z_Area.global_position.y = global_position.y - z_floor
	#ーーーーーーージャンプ機構ーーーーーーーーー
	# スペースキーを押してジャンプ状態になる
#	if Input.is_action_just_pressed("jump"):  
#		if z <= z_floor: 
#			jump = true 
#			$bodyCollision.disabled = true
	
	# ジャンプ状態である間、Z座標にz_speedの値を加算
#	if jump == true: 
#		z += z_speed 
	
	# Z座標が地面の高さより大きい（空中にいる）場合は少しずつ下降する力が増えていく
#	if z >= z_floor: 
#		z -= z_grav * 0.9
#		z_grav = z_grav + grav_rate 
	
	# Z座標が地面の高さより小さい（地上にいる）場合はジャンプ状態を終了する
#	if z <= z_floor + 1: 
#		z = z_floor 
#		z_grav = 0 
#		jump = false 
#		$bodyCollision.disabled = false

	# ジャンプに合わせてプレイヤーの画像と当たり判定を動かす 
#	$PlayerIcon.global_position.y = global_position.y - z 
#	$bodyCollision.global_position.y = global_position.y - z + 10
#	ーーーーーーーーーーーーーーーーーーーーーーーーー
	pass


func _ready():#Sceneが全て実体化(インスタンス化)が終わってから実行
#	setting()
	can_move = false
	pass

#初期化設定
func setting():
	hurtboxCollision.set_deferred("disabled", false)
	can_move = true
	
#	print(get_parent().get_gameManager())
	stats.connect("no_health", get_parent().get_gameManager(), "player_dead")
	stats.connect("no_health", self, "death_Process")
	
	$HitboxPivot/SwordHitbox/CollisionShape2D.disabled = true
#	animationTree.active = true
	
	#ノックバック方向の代入
	knockback_vector = roll_vector
	
	stateMatchine.ChangeState(moveState)
	
	now_duelSystem = false
	
	input_vector = Vector2.RIGHT
	is_look_right = true
	pass

func _process(delta):
	#-----------近くの敵を格納する変数-----------
#	target_enemy = enemyDetrctionZone.Enemy
#	if (target_enemy != null):
#		target_enemy_pos = target_enemy.global_position

#	if now_duelSystem:
	get_parent().get_ClosestTarget_fromPlayer()
	target_enemy = charaList.targetChara
#	print(is_instance_valid(target_enemy))
	if(is_instance_valid(target_enemy) || target_enemy != null):
		target_enemy_pos = target_enemy.global_position
		
	#---------------------------------
	
	#ーーーーーーーTileMap検知(地面の高さ処理)ーーーーーーーーー
	for i in get_slide_count():
		var collision = get_slide_collision(i)
		if collision:
			var tilemap := collision.collider_shape as TileMap
			if tilemap:
				var tileset := tilemap.tile_set
				var tile_pos = Physics2DServer.body_get_shape_metadata(
					collision.collider.get_rid(),
					collision.collider_shape_index)
				var tile_id := tilemap.get_cellv(tile_pos)
				print(tileset.tile_get_name(tile_id));
#			emit_signal('collided', collision)
			pass
	#ーーーーーーーーーーーーーーーーー

func _physics_process(delta):#設定された秒数ごとに一定間隔で呼び出される関数。unityのrun()
	if now_duelSystem:
		#---------duelシステム起動時に山形に移動する機構-------------
		if z < 500:
			z += get_gravity() * delta

		if get_parent().player_duelPos_save.y <= icon.global_position.y:
			z = 0
		icon.global_position.y += (z * 0.01)
		#-------------------------------------------------------
	
	
	delta_scope = delta
	
	#-------knockbackの移動処理------------
	knockback = knockback.move_toward(Vector2.ZERO, FRICTION * delta)
	knockback = move_and_slide(knockback)
	#-------------------------------------
	
	stateMatchine.Update()
	
func move_state(delta):
#	input_vector = Vector2.ZERO
#	input_vector.x = (Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"))
#	if input_vector.x != 0:
#		initial_attack_vector = input_vector
#	input_vector.y = (Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up"))
#	input_vector = input_vector.normalized()
#
#	if input_vector != Vector2.ZERO:
#		roll_vector = input_vector
#		#attack_vector = input_vector
#		swordHitbox.knockback_vector = input_vector
#		animationTree.set("parameters/Idle/blend_position", input_vector)
#		animationTree.set("parameters/Run/blend_position", input_vector)
#
#		animationTree.set("parameters/Attack1/blend_position", input_vector)
#		animationTree.set("parameters/Attack2/blend_position", input_vector)
#		animationTree.set("parameters/Attack3/blend_position", input_vector)
#
#		animationTree.set("parameters/Roll/blend_position", input_vector)
#		animationState.travel("Run")
#
#		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
##		print(stats.Acceleration)
##		velocity = velocity.move_toward(input_vector * MAX_SPEED, stats.Acceleration * delta)
#
#	else:
##		animationPlayer.play("Idle Right")		
#		#animationTree.set("parameters/Idle/blend_position", input_vector)
#		animationState.travel("Idle")
#		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
#
#	move()
	
#	if Input.is_action_just_pressed("attack"):
#		state = player_state.ATTACK1
#	if Input.is_action_just_pressed("roll"):
#		state = player_state.ROLL
#
#	if Input.is_action_just_pressed("jump"):
#		#state = JUMP
#		pass
#	if Input.is_action_just_pressed("action"):
##		state = player_state.DUEL
#		camera.current = false
	pass
		
func move():
	velocity = move_and_slide(velocity)# * delta

#敵に攻撃が当たった際に呼び出される関数
func now_hitAttack():
	if !attackSE.playing:
		match stateMatchine._get_CurrentState():
			attack1State:
				attackSE.pitch_scale = 1.1
				attackSE.play()
				stats.ex_point += 2
			attack2State:
				attackSE.pitch_scale = 1.1
				attackSE.play()
				stats.ex_point += 2
			attack3State:
				attackSE.pitch_scale = 1.2
				attackSE.play()
				stats.ex_point += 2
			duelState:
				duel_attackSE.play()
				stats.ex_point += 20
			

func hit_SE_stop():
	attackSE.play()

#statsのpowを参照して、攻撃モーションごとにdamageの値を更新する関数
func change_attackPow(magnification : int):
	stats.power = magnification
#	swordHitbox.change_Damage(magnification * stats.power)
	pass
	
#攻撃アニメーションを再生時、近くの敵に向かうvectorを生成する関数
func attackVectorCreate():
	if target_enemy != null && target_enemy_pos != null:
		target_enemy_pos = target_enemy.global_position
		attack_vector = (target_enemy_pos - global_position).normalized()
		
		#攻撃時に向きが変わった際に、その方向に合わせたknockbackを作成
		var correction_knockback_vector = roll_vector
		
		if attack_vector.x != 0:
			correction_knockback_vector.x = attack_vector.x / sqrt(pow(attack_vector.x, 2) + pow(attack_vector.y, 2))
#		if  attack_vector.y != 0 :
#			correction_knockback_vector.y = attack_vector.y / sqrt(pow(attack_vector.y, 2) + pow(attack_vector.y, 2))
		
#		swordHitbox.knockback_vector = correction_knockback_vector
		knockback_vector = correction_knockback_vector
	else:
		attack_vector = initial_attack_vector

#攻撃時に移動する処理
func chase_enmey_move(delta):
	velocity = Vector2.ZERO
#	var findEnemyStep = 1
	if target_enemy != null && target_enemy_pos != null:
		velocity = velocity.move_toward(attack_vector * STEP_SPEED * findEnemyStep, ACCELERATION * delta * 64)
	else:
		velocity = velocity.move_toward(attack_vector * STEP_SPEED, ACCELERATION * delta * 64)
#		findEnemyStep = 2
#	print(attack_vector)
#	velocity = velocity.move_toward(attack_vector * 10, ACCELERATION * delta * 64)
#	print(velocity)
	
	velocity = move_and_slide(velocity)
#	return attack_direction

func attack_state(delta, attackType):
#	chase_enmey_move(delta)
#
#	match attackType:
#		player_state.ATTACK1:
#			swordHitbox.change_Knockback_Pow(knockback_pow)
#			animationState.travel("Attack1")
#			animationTree.set("parameters/Attack1/blend_position", attack_vector)
#		player_state.ATTACK2:
#			swordHitbox.change_Knockback_Pow(knockback_pow)
#			animationState.travel("Attack2")
#			animationTree.set("parameters/Attack2/blend_position", attack_vector)
#		player_state.ATTACK3:
#			swordHitbox.change_Knockback_Pow(knockback_pow * 3)
#			animationState.travel("Attack3")
#			animationTree.set("parameters/Attack3/blend_position", attack_vector)
#	if Input.is_action_just_pressed("attack") && canNextCombo:
##		match state:
##			player_state.ATTACK1:
##				state = player_state.ATTACK2
##			player_state.ATTACK2:
##				state = player_state.ATTACK3
#		canNextCombo = false
	pass

func nextAttackTiming():
	canNextCombo = true

func attack_animation_finished():
#	state = player_state.MOVE
	canNextCombo = false
	#攻撃時に向いた方向にアニメーション終了時に向くように修正
	if roll_vector.x > 0:
		animationPlayer.play("IdleRight")
	else :
		animationPlayer.play("IdleLeft")
#	animationTree.set("parameters/Idle/blend_position", attack_vector)
	
	stateMatchine.ChangeState(moveState)
	
func roll_state(delta):
	velocity = roll_vector * ROLL_SPEED
#	animationState.travel("Roll")
	#Roll中に敵との当たり判定を一定時間消す処理
	k_body.set_collision_mask_bit(4, false)
#	k_body.set_collision_layer_bit(6, false)
	
	hurtbox.monitoring = false
	move()
	
func roll_aimation_finished():
	velocity /= 2
	#敵との当たり判定を復活させる処理
	k_body.set_collision_mask_bit(4, true)
#	k_body.set_collision_layer_bit(6, true)
	
	hurtbox.monitoring = true
	stateMatchine.ChangeState(moveState)
#	state = player_state.MOVE

#ダメージアニメーション終了時の処理
func damage_animation_finished():
	if !now_duelSystem:
		stateMatchine.ChangeState(moveState)
		animationPlayer.stop(true)
	pass

#無敵時間終了時の処理
func _on_InvincibleTime_timeout():
	hurtboxCollision.set_deferred("disabled", false)
	pass # Replace with function body.

#duelSystem中に行動をしたら、他の行動が行えないようにする関数
func duel_action_start():
	now_duelAction = true

#duelSystem中のカウンターアニメーション終了時の処理
func duelCounter_animation_finished():
	now_duelAction = false
#	animationPlayer.stop()
#	animationPlayer.play("IdleRight")
	
#duelSystem中の回避アニメーション終了時の処理
func duelRoll_animation_finished():
#	print("finish duel Roll")
	now_duelAction = false
	k_body.set_collision_mask_bit(4, true)
	hurtbox.monitoring = true
	animationPlayer.play("IdleRight")
	print(now_duelAction)

func move_duelStage(pos):
	var tween:Tween = Tween.new()
	
	now_duelSystem = true
	
	animationPlayer.stop()
	
	jump()
	
	if is_look_right:
		animationPlayer.play("R_moveDuel")
	else:
		animationPlayer.play("L_moveDuel")
	
	tween.interpolate_property(self, "position", position, pos, 1.0, Tween.TRANS_EXPO, Tween.EASE_OUT)
	tween.interpolate_callback(self, 1.0, "move_duelStage_complete")
#
	add_child(tween)
	tween.start()

#	tween.set_ease(Tween.EASE_IN_OUT)
#	tween.set_trans(Tween.TRANS_EXPO)
#	tween.tween_property (self, "position", pos, 0.5)
#	tween.tween_callback(self, "move_duelStage_complete")
#	tween.play()
	pass

func move_duelStage_complete():
#	input_vector = Vector2.ZERO
#	input_vector.x = 1
#	animationTree.set("parameters/Idle/blend_position", input_vector)
#	animationState.travel("Idle")
#	print("move completed")

	animationPlayer.play("IdleRight")
	stateMatchine.ChangeState(duelState)
	pass

func _on_HurtBox_area_entered(area):
#	stats.health -= area.damage
	stats.health -= area.get_owner().stats.power
	hurtbox.start_invincibility(0.5)#無敵時間の設定
	hurtbox.create_hit_effect(global_position)#ヒット時の演出の作成
	
	#ダメージアニメーションを移行するstate
	stateMatchine.ChangeState(damageState)
	
	#攻撃を受けた時にknockbackの値を作成する
#	knockback = area.knockback_vector * area.knockback_pow
#	print("vector :" + str(area.get_owner().knockback_vector))
#	print("pow :" + str(area.get_owner().knockback_pow))
	knockback = area.get_owner().knockback_vector * area.get_owner().knockback_pow

	if now_duelSystem:
#		get_parent().end_duelSystem()
		print("duel damage Player !!!!")
		print(emit_signal("duel_damage"))
		emit_signal("duel_damage")
		pass
	
#	if now_duelSystem:
#		print("end duel")
#		get_parent().end_duelSystem()
#		now_duelSystem = false
#		pass

func death_Process():
	#死亡時アニメーションの作成
#	$PlayerIcon.visible = false
	pass

class PlayerIdleState extends StateTemp:
	func _enter(m_Owner):
		print("state : move")
		m_Owner.now_duelSystem = false
#		m_Owner.animationState.travel("Idle")
		pass
	
	func _execute(m_Owner):
		if m_Owner.can_move:
			m_Owner.input_vector = Vector2.ZERO
			m_Owner.input_vector.x = (Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"))
			if m_Owner.input_vector.x != 0:
				m_Owner.initial_attack_vector = m_Owner.input_vector
			m_Owner.input_vector.y = (Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up"))
			m_Owner.input_vector = m_Owner.input_vector.normalized()
			
			if m_Owner.input_vector != Vector2.ZERO:
				m_Owner.roll_vector = m_Owner.input_vector
				
				m_Owner.knockback_vector = m_Owner.input_vector
	#			m_Owner.animationTree.set("parameters/Idle/blend_position", m_Owner.input_vector)
	#			m_Owner.animationTree.set("parameters/Run/blend_position", m_Owner.input_vector)
	#			m_Owner.animationState.travel("Run")
				if !m_Owner.now_duelSystem : 
					if m_Owner.roll_vector.x == 0:
						if m_Owner.is_look_right:
							m_Owner.animationPlayer.play("RunRight")
							m_Owner.is_look_right = true
						else :
							m_Owner.animationPlayer.play("RunLeft")
							m_Owner.is_look_right = false
					else :
						if m_Owner.roll_vector.x > 0:
							m_Owner.animationPlayer.play("RunRight")
							m_Owner.is_look_right = true
						else : 
							m_Owner.animationPlayer.play("RunLeft")
							m_Owner.is_look_right = false
					
				m_Owner.velocity = m_Owner.velocity.move_toward(m_Owner.input_vector * m_Owner.MAX_SPEED, m_Owner.ACCELERATION)
				
			else:
	#			m_Owner.animationTree.set("parameters/Idle/blend_position", m_Owner.roll_vector)
	#			m_Owner.animationState.travel("Idle")
				
				if !m_Owner.now_duelSystem : 
					if m_Owner.is_look_right:
						m_Owner.animationPlayer.play("IdleRight")
					else : 
						m_Owner.animationPlayer.play("IdleLeft")

				m_Owner.velocity = m_Owner.velocity.move_toward(Vector2.ZERO, m_Owner.FRICTION)
				
			m_Owner.velocity = m_Owner.move_and_slide(m_Owner.velocity)# * delta
			
			if Input.is_action_just_pressed("attack"):
				m_Owner.stateMatchine.ChangeState(m_Owner.attack1State)
			if Input.is_action_just_pressed("roll"):
				m_Owner.stateMatchine.ChangeState(m_Owner.rollState)
				
			if Input.is_action_just_pressed("jump"):
	#			m_Owner.is_floot = false
				m_Owner.icon.global_position.y = m_Owner.global_position.y
	#			m_Owner.jump()
				pass
				
			if Input.is_action_just_pressed("action"):
				print(m_Owner.target_enemy.will_attack_class)
				if m_Owner.stats.ex_point > 99:
					m_Owner.stateMatchine.ChangeState(m_Owner.exAttackState)
					pass
				else:
					m_Owner.get_parent().start_duelSystem(m_Owner.target_enemy)
	#			m_Owner.stateMatchine.ChangeState(m_Owner.actionState)
	#			m_Owner.camera.current = false
				pass
	
	func _exit(m_Owner):
		pass

class PlayerAttack1State extends StateTemp:
	func _enter(m_Owner):
		print("state : attack1")
		m_Owner.attackVectorCreate()
		m_Owner.knockback_pow = 60
		m_Owner.change_attackPow(1)
		
#		m_Owner.swordHitbox.change_Knockback_Pow(m_Owner.knockback_pow)
		
#		m_Owner.animationTree.set("parameters/Attack1/blend_position", m_Owner.attack_vector)
#		m_Owner.animationState.travel("Attack1")

		if m_Owner.attack_vector.x > 0:
			m_Owner.animationPlayer.play("Rattack1")
			m_Owner.is_look_right = true
		else : 
			m_Owner.animationPlayer.play("Lattack1")
			m_Owner.is_look_right = false
		
	func _execute(m_Owner):
		m_Owner.chase_enmey_move(m_Owner.delta_scope)
		
		if Input.is_action_just_pressed("attack") && m_Owner.canNextCombo:
			m_Owner.stateMatchine.ChangeState(m_Owner.attack2State)
			pass
	
	func _exit(m_Owner):
		m_Owner.canNextCombo = false
		m_Owner.swordHitbox_collision.disabled = true
		pass
	pass

class PlayerAttack2State extends StateTemp:
	func _enter(m_Owner):
		print("state : attack2")
		m_Owner.attackVectorCreate()
		m_Owner.knockback_pow = 60
		m_Owner.change_attackPow(1)
#		m_Owner.swordHitbox.change_Knockback_Pow(m_Owner.knockback_pow)
		
#		m_Owner.animationTree.set("parameters/Attack2/blend_position", m_Owner.attack_vector)
#		m_Owner.animationState.travel("Attack2")

		if m_Owner.attack_vector.x > 0:
			m_Owner.animationPlayer.play("Rattack2")
			m_Owner.is_look_right = true
		else : 
			m_Owner.animationPlayer.play("Lattack2")
			m_Owner.is_look_right = false
	
	func _execute(m_Owner):
		m_Owner.chase_enmey_move(m_Owner.delta_scope)
		
		if Input.is_action_just_pressed("attack") && m_Owner.canNextCombo:
			m_Owner.stateMatchine.ChangeState(m_Owner.attack3State)
			pass
	
	func _exit(m_Owner):
		m_Owner.swordHitbox_collision.disabled = true
		pass
	pass

class PlayerAttack3State extends StateTemp:
	func _enter(m_Owner):
		print("state : attack3")
		m_Owner.attackVectorCreate()
		m_Owner.knockback_pow = 250
		m_Owner.change_attackPow(3)
#		m_Owner.swordHitbox.change_Knockback_Pow(m_Owner.knockback_pow)
		
#		m_Owner.animationTree.set("parameters/Attack3/blend_position", m_Owner.attack_vector)
#		m_Owner.animationState.travel("Attack3")

		if m_Owner.attack_vector.x > 0:
			m_Owner.animationPlayer.play("Rattack3")
			m_Owner.is_look_right = true
		else : 
			m_Owner.animationPlayer.play("Lattack3")
			m_Owner.is_look_right = false
		
	func _execute(m_Owner):
		m_Owner.chase_enmey_move(m_Owner.delta_scope)
		pass
		
	func _exit(m_Owner):
		m_Owner.swordHitbox_collision.disabled = true
		pass

class PlayerEXAttackState extends StateTemp:
	func _enter(m_Owner):
		print("state : attack3")
		m_Owner.attackVectorCreate()
		m_Owner.knockback_pow = 250
		m_Owner.change_attackPow(6)
#		m_Owner.swordHitbox.change_Knockback_Pow(m_Owner.knockback_pow)
		
#		m_Owner.animationTree.set("parameters/Attack3/blend_position", m_Owner.attack_vector)
#		m_Owner.animationState.travel("Attack3")
		m_Owner.animationPlayer.play("R_EXattack")
		
	func _execute(m_Owner):
		pass
		
	func _exit(m_Owner):
		m_Owner.swordHitbox_collision.disabled = true
		pass

class PlayerRollState extends StateTemp :
	func _enter(m_Owner):
		print("state : roll")
		
#		m_Owner.animationTree.set("parameters/Roll/blend_position", m_Owner.roll_vector)
#		m_Owner.animationState.travel("Roll")

		if m_Owner.roll_vector.x > 0:
			m_Owner.animationPlayer.play("RollRight")
			m_Owner.is_look_right = true
		else : 
			m_Owner.animationPlayer.play("RollLeft")
			m_Owner.is_look_right = false
		pass
		
	func _execute(m_Owner):
		m_Owner.velocity = m_Owner.roll_vector * m_Owner.ROLL_SPEED
		
		#Roll中に敵との当たり判定を一定時間消す処理
		m_Owner.k_body.set_collision_mask_bit(4, false)
	#	k_body.set_collision_layer_bit(6, false)
		m_Owner.hurtbox.monitoring = false
		
		m_Owner.velocity = m_Owner.move_and_slide(m_Owner.velocity)
		pass

	func _exit(m_Owner):
		pass
		
	pass
	
class PlayerDuelState extends StateTemp:
	func _enter(m_Owner):
		m_Owner.now_duelSystem = true
		print("duel state")
		m_Owner.knockback_pow = 250
		m_Owner.change_attackPow(5)
#		m_Owner.swordHitbox.change_Knockback_Pow(m_Owner.knockback_pow)
#		m_Owner.animationTree.active = false
		pass
		
	func _execute(m_Owner):
		
		if Input.is_action_just_pressed("attack") && !m_Owner.now_duelAction:
			m_Owner.animationPlayer.play("DuelCounter")
#		if Input.is_action_just_pressed("roll") && !m_Owner.now_duelAction:
#			m_Owner.animationPlayer.play("DuelRoll")
		pass

	func _exit(m_Owner):
#		m_Owner.animationPlayer.stop()
#		m_Owner.animationTree.active = true
		m_Owner.now_duelAction = false
		m_Owner.swordHitbox_collision.set_deferred("disabled", true)

#		m_Owner.now_duelSystem = false
#		m_Owner.animationTree.active = true
#		m_Owner.animationState.travel("Idle")
		pass
		
	pass

class PlayerDamageState extends StateTemp :
	func _enter(m_Owner):
		print("state : damage")
#		m_Owner.animationTree.set("parameters/Damage/blend_position", m_Owner.roll_vector)
#		m_Owner.animationState.travel("Damage")

		m_Owner.animationPlayer.stop(false)
		if m_Owner.is_look_right:
			m_Owner.animationPlayer.play("R_damage")
			m_Owner.is_look_right = true
		else : 
			m_Owner.animationPlayer.play("L_damage")
			m_Owner.is_look_right = false
		pass

		m_Owner.hurtboxCollision.set_deferred("disabled", true)
		m_Owner.invincibleTimer.start(0.2)
		pass
		
	func _execute(m_Owner):
		#damageAnimationを再生
		pass

	func _exit(m_Owner):
		pass
		
	pass
