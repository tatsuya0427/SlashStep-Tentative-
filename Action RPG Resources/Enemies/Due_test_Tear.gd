extends KinematicBody2D

const EnemyDeathEffect = preload("res://Action RPG Resources/Effects/EffectPlayer.tscn")




#------------------------------で囲んだところ以外はインスタンス化できそう。動画見終わったらそれをやってオリジナルのてきに適用しよう

#キャラクターのステータスをまとめたクラス-------
onready var stats = $Stats
export (int) var ACCELERATION = 300
export (int) var MAX_SPEED = 40
export (int) var FRICTION = 800
#-------------------------------------------

#-------------移動速度関係----------------
#processのdeltaを格納しておく変数
var scope_delta
#------------------------------

#-------------SE関係----------------
#processのdeltaを格納しておく変数
onready var damage_SE = $damageSE
#------------------------------

#-------------StateMachine関係-----------------
enum myState{
	IDLE,
	WANDER,
	CHASE,
	STAYNEAR,
	ATTACK,
	DAMAGE
}

#状態遷移を司るステートマシン
onready var stateMatchine = StateMatchine.new(self)

#各状態のステート内容を格納する変数
onready var idleState = TearIdleState.new()
onready var chaseState = TearChaseState.new()
onready var stayNearState = TearStayNearState.new()
onready var attackState = TearAttackState.new()
onready var duel1State = TearDuel1State.new()
onready var duelStayState = TearDuelStayState.new()
onready var damageState = TearDamageState.new()
onready var deathState = TearDeathState.new()
onready var ex_stay = TearEX_AttackStayState.new()

#このキャラクターが生きているかどうか
onready var live = true

#var state = myState.IDLE
#var stun_before_state = state
#var stun = false#trueなら行動不能

#このキャラクターの移動方向を司る変数
var velocity = Vector2.ZERO
#このキャラクターが吹っ飛ぶ力
var knockback = Vector2.ZERO
#このキャラクターの向いている値
var direction = Vector2.ZERO
var is_look_right : bool = false


#-----------------追跡関係---------------------
#onready var playerDetrctionZone = $TargetDetectionTemp
onready var playerDetrctionZone = $jump_move/Image/PlayerDetectionZone
#----------------------------------------------

#--------------アニメーション関係----------------
onready var image = $jump_move/Image
onready var anim = $AnimationPlayer
#現在再生しているアニメーション名を格納しておく変数
var  now_play_anim = ""
#onready var animationSprite = $AnimatedSprite
#onready var tearImage = $TearImage
onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")
#----------------------------------------------
onready var hurtbox = $jump_move/Image/HurtBox
onready var hurtboxCollision = $jump_move/Image/HurtBox/CollisionShape2D
onready var softCollision = $jump_move/Image/SoftCollision
onready var softCollision_col = $jump_move/Image/SoftCollision/CollisionShape2D

#死亡時、少しディレイをかけてから志望エフェクトを生成する
onready var death_timer = $death_direction_timer
#------------------------怯み関係------------------------
#攻撃を受けてから、敵が再び動けるようになるまでのタイマー
#onready var stunTimer = $STUNTimer
#ダメージ中にダメージを受けた時にtrueにし、ダメージアニメーションをリセットする関数を起動する
#var next_DamageFlag = false
#-------------------------------------------------------

#------------------------追跡関係------------------------
#追いかけているplayerSceneを格納
var player = null

#CharaListにて、playerにターゲットされている敵はtrueにし、死亡時に別ターゲットを指定する信号を送信する
onready var targeting:bool = false setget set_targeting
onready var targetImage = $jump_move/Image/Target
onready var pop = $Label

#-------------------------------------------------------

#------------------------攻撃関連------------------------
#攻撃時のふっとばし力(statsに移行)
#export var knockback_pow = 30
#var knockback_vector = Vector2.LEFT
#STAYNEAR状態になった際に、ランダムな秒数後、Playerが近いなら攻撃を行い、遠い場合にはIdle状態になる
onready var nextActionTimer = $NextActionTimer

#knockbackやDamageの値はこのクラスから変更する
onready var hitBox = $jump_move/Image/HitBoxPivot/HitBox
#攻撃の当たり判定の処理
onready var hitBoxCol = $jump_move/Image/HitBoxPivot/HitBox/CollisionShape2D
#attackTimerが設定された際にはtrueになり、追加でattackTimerが設定されないようにする
#var will_attack = false

#攻撃内容を格納しておく配列
var attackList = []
#次に行う攻撃Stateを格納する変数
var will_attack_class : AttackPattern

#残像を作成するスクリプトの代入
#export var ghostEffect = $GhostEffect
#export(String, FILE, "*.tscn") var ghostEffect
const ghostEffect = preload("res://Action RPG Resources/Effects/TearGhostEffect.tscn")
#攻撃時に残像を作る数
var ghost_cnt = 0

#現在のimageフレームを取得ためのnode
#onready var image = $Image

#攻撃時に赤く光る機能
onready var fadeAnimation = $jump_move/Image/FadeAnimation

#-----------デュアルシステム関係----------------
#tear自身の当たり判定
onready var body_col = $CollisionShape2D
#デュアルシステムの攻撃当たり判定
#onready var duel_hitBox = $jump_move/duel_HitBox
#onready var duel_hitBox_Col = $jump_move/duel_HitBox/CollisionShape2D
#デュアルシステムを起動できる攻撃時に頭上に表示する画像
onready var attentionImage = $jump_move/Image/AttentionImage
#デュアルシステムを起動できる状態にある場合にはtrueに
onready var can_duelFlag = false
#現在、デュアルシステムの対象のキャラになっているかどうか。対象ならばtrue
onready var now_duelFlag = false
#duelシステム起動時の吹っ飛ぶ量
var duel_knockback = Vector2.ZERO
#duelシステム時にplayerにダメージを与えて終了アニメーションを流す際に指定する変数
var duel_end_animation = ""
#-------------------------------------------------------

#------------------------waveEnemy関係------------------
#死亡時にwaveSceneに信号を送るシグナル
signal death
var do_connect_wave = false

#敵撃破時に獲得できるScoreを設定する
export var enemy_Score = 100
#-------------------------------------------------------

#-------------------死亡時アニメーション関係---------------
#-------------------------------------------------------

#-------------------ジャンプ、吹っ飛び関係---------------
onready var _jump_process = $jump_move
#-------------------------------------------------------

#コンストラクタ
func init():
	pass

#waveの時に生成される敵にはこの関数を実行
func set_WaveEnemy():
#	waveManager.connect("destroySignal", waveManager, "destroy_Wave_Enemy")
	do_connect_wave = true
	#敵生成アニメーションを作成
	
#func set_StateParameters(type, value):
#	match type:
#		"power":
#			hitBox.damage = value
#		"knockback_power":
#			hitBox.knockback_pow = value
			
func _ready():
	hurtboxCollision.set_deferred("disabled", false)
	
	stats.connect("no_health", self, "_on_Stats_no_health")
#	$HitBoxPivot/HitBox/CollisionShape2D.disabled = true
	stateMatchine.ChangeState(idleState)

#	animationTree.active = true
	nextActionTimer.one_shot = true
#	if():
#	set_StateParameters("power", power)
	
#	ACCELERATION = stats.Acceleration
#	MAX_SPEED = stats.MaxSpeed
#	FRICTION = stats.Friction

	image.position.x = 0
	image.position.y = 0
	
	targetImage.visible = false
	
	attentionImage.visible = false
	
	
	can_duelFlag = false
	now_duelFlag = false
	
	softCollision_col.set_disabled(false)
	
	attackList.push_back(AttackPattern.new(attackState, null, false, "NailAttackEffect"))
	attackList.push_back(AttackPattern.new(attackState, duel1State, true, "NailAttackEffect"))

func _physics_process(delta):
	
	scope_delta = delta
	
	knockback = knockback.move_toward(Vector2.ZERO, FRICTION * delta)
	duel_knockback = duel_knockback.move_toward(Vector2.ZERO, FRICTION * delta)
#	knockback = knockback.move_toward(Vector2.ZERO, stats.Friction * delta)
	
	stateMatchine.Update()
	
	#------------------------------
	if softCollision.is_colliding():#敵同士が重ならないようにする機構
		velocity += softCollision.get_push_vector() * delta * 100


	#移動する処理ーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー
	velocity = move_and_slide(velocity)

	#ノックバックで吹っ飛ぶ処理
	knockback = move_and_slide(knockback)
#	duel_knockback = duel_body.move_and_slide(duel_knockback)
	
	fadeAnimation.view_Effect(image.frame)

#------------------------------

func play_anim(play_name:String):
	anim.play(play_name)
	now_play_anim = play_name
	pass

#ターゲットになった場合に、ターゲットカーソルの表示とbool変数に格納
func set_targeting(value:bool):
	targeting = value
	targetImage.visible = value
	#targetがtrueの時にもしcan_duelFlag = trueならattentionImageを可視化する
	if can_duelFlag and value:
		attentionImage.visible = true
	else:
		attentionImage.visible = false
	#targetingされた敵のHPをUIとして設定する
	stats.set_healthUI(value)

#デュアルシステムが起動可能か否かを切り替える関数
func switch_DuelFlag(flag:bool):
	if flag:
		if targeting:
			attentionImage.visible = true
		can_duelFlag = true
	else:
		attentionImage.visible = false
		can_duelFlag = false
	pass

#CharaListから、DuekSystemが起動された場合の変更処理
func execution_DuelAttack(target : bool):
	can_duelFlag = false
	if target:
		now_duelFlag = true
	else :
		stateMatchine.ChangeState(duelStayState)
		now_duelFlag = false

#CharaListから、DuekSystemが終了した時の変更処理
func end_DuelAttack():
#	softCollision_col.set_disabled(false)
#	 + get_parent().enemy_duelPos.position
	
	softCollision_col.set_deferred("disabled", false)
	if now_duelFlag :
		now_duelFlag = false
#		image.global_position.x = 0
#		image.global_position.y = 0
		
	else:
		stateMatchine.RevertToPreviousState()
	pass

func move_duelStage(pos):
	nextActionTimer.stop()
	
	var tween:Tween = Tween.new()
	
#	softCollision_col.set_disabled(true)
	softCollision_col.set_deferred("disabled", true)
	tween.interpolate_property(self, "position", position, pos, 1.0, Tween.TRANS_EXPO, Tween.EASE_OUT)
	tween.interpolate_callback(self, 1.0, "move_duelStage_complete")
	
	add_child(tween)
	tween.start()
	pass
	
func move_duelStage_complete():
#	image.visible = true
#	duel_image.visible = false
	
	play_anim("IdleLeft")
	stateMatchine.ChangeState(will_attack_class.get_duelAttack())
#	stateMatchine.ChangeState(duel1State)
	pass
	
#player側から、duelシステム時にダメージを与えた時に送られてくるシグナル
func duel_attack_endAnimation():
	print("duel damage!!!!")
	if duel_end_animation != "":
		var image_pos = image.position
		image.position.x = 0
		image.position.y = 0
		position = image_pos + position
		play_anim(duel_end_animation)
		get_parent().end_duelSystem()
		
	else:
		print("duel_end_animation is not string")
	pass

func duel_rollAttack_finish():
	var image_pos = image.position
	image.position.x = 0
	image.position.y = 0
	position = image_pos + position
	stateMatchine.ChangeState(idleState)
	pass

#playerがexAttackをした時に実行する関数
func ex_attack_start():
	stateMatchine.ChangeState(ex_stay)
	pass
	
func ex_attack_end():
	stateMatchine.RevertToPreviousState()

#次の攻撃をランダムに選択する
func chose_attack():
	#ここでランダムに攻撃パターンを選択する
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	#ここの乱数の最大値は攻撃パターンを配列にして上限を変更できるように後々修正
	#duelなら、頭上に！を表示する
	will_attack_class = attackList[rng.randi_range(0, attackList.size() - 1)]
	if will_attack_class.is_duel:
		switch_DuelFlag(true)
		nextActionTimer.start(rand_range(1.0, 3.0))
#		print("--------------------")
#		print("will_attack_class")
#		print(will_attack_class)
#		print("--------------------"
	else:
		nextActionTimer.start(rand_range(0.3, 1.5))

func create_attackVector():
#	print(playerDetrctionZone.can_see_player())
	if playerDetrctionZone.can_see_player():
		var distanceData = (player.global_position - global_position).normalized()
		var correction_knockback_vector = Vector2.ZERO
		
#		print(player)
#		print("distanceData :" + str(distanceData))
		
		if distanceData.x != 0 :
			correction_knockback_vector.x = distanceData.x / sqrt(pow(distanceData.x, 2) + pow(distanceData.y, 2))

		if distanceData.y != 0 :	
			correction_knockback_vector.y = distanceData.y / sqrt(pow(distanceData.x, 2) + pow(distanceData.y, 2))
			
#		hitbox_node.knockback_vector = correction_knockback_vector
		stats.knockback_vector = correction_knockback_vector
	pass

func _on_NextActionTimer_timeout():
	create_attackVector()
	if can_duelFlag:
		switch_DuelFlag(false)
	
#	if playerDetrctionZone.can_see_player():
#		var distanceData = (player.global_position - global_position).normalized()
#		var correction_knockback_vector = Vector2.ZERO
#		correction_knockback_vector.x = distanceData.x / sqrt(pow(distanceData.x, 2) + pow(distanceData.y, 2))
#		correction_knockback_vector.y = distanceData.y / sqrt(pow(distanceData.x, 2) + pow(distanceData.y, 2))
#		hitBox.knockback_vector = correction_knockback_vector
#		stateMatchine.ChangeState(will_attack_state)
#		stateMatchine.ChangeState(idleState)

	stateMatchine.ChangeState(will_attack_class.get_normalAttack())
	stats.target_effect = will_attack_class.effect_pattern
	pass # Replace with function body.

#---------------------ダメージ＋怯み関係------------------------
func _on_HurtBox_area_entered(area):
	print("damage!")
	print("- - - - -")
	velocity = Vector2.ZERO
	damage_SE.play()
#	stats.health -= area.damage
#	if now_duelFlag
#		stats.health -= stats.health - 1
#	else:
	var target = null
	if area.get_owner().name == "Player":
		target = area.get_owner()
	else:
		target = area.get_owner().get_owner()
	stats._health -= target.stats._power
	
#	knockback = area.knockback_vector * area.knockback_pow
	knockback = target.stats.knockback_vector * target.stats.knockback_pow
	if knockback.x != 0 && knockback.y != 0:
		knockback.x = knockback.x / 1.4
		knockback.y = knockback.y / 1.4
	hitBoxCol.set_deferred("disabled", true)
	
	if !(target.stats._float_pow == 0):
		stats._hurt_float_pow = target.stats._float_pow
	
	stateMatchine.ChangeState(damageState)
	
	target.now_hitAttack()

	if now_duelFlag:
		var image_pos = image.position
		image.position.x = 0
		image.position.y = 0
		position = image_pos + position
#		duel_hitBox_Col.set_deferred("disabled", true)
#		duel_hitBox_Col.disabled = false
#		get_parent().frameFreeze(0.05, 1.0)
#		hurtbox.create_hit_effect(image.position)
		get_parent().duelEnd_frameFreeze(0.05, 1.0)
#		global_position = duel_image.global_position
#		get_parent().end_duelSystem()

	hurtbox.create_hit_effect(global_position, target.stats.target_effect)
	
#-------------------------------------------------------

func damage_animation_Finish():
#	state = IDLE
#	change_State(myState.IDLE)
#	next_DamageFlag = false
#	animatedSprite.visible = false
#	tearImage.visible = true
	stateMatchine.ChangeState(idleState)
	pass

func _on_Stats_no_health():
	live = false
	#もし、target自身がターゲットされている場合、別の一番近い的をターゲットするための処理をさせる。
#	if targeting:
#		get_parent().get_ClosestTarget_fromPlayer()
#		pass
	
	stateMatchine.ChangeState(deathState)
	death_timer.start(0.5)
	

func _on_death_direction_timer_timeout():
	stats.set_healthUI(false)
	stats.deathProcess()
	_proc_ghost_effect(Color(255, 255, 255, 255), 1.0)
	var enemyDeathEffect = EnemyDeathEffect.instance()
	get_parent().add_child(enemyDeathEffect)
	enemyDeathEffect.global_position = global_position
	enemyDeathEffect._play_effect("EnemyDeathEffect")

	#もし、waveEnemyの場合、死亡時にwaveManagerでカウントする信号を送る
	if(do_connect_wave):
		GameStats.set_Score(enemy_Score)
		emit_signal("death", self)

func attack_Animation_Finish():
	stateMatchine.ChangeState(idleState)
	pass
	

# 残像エフェクトの処理	
func _proc_ghost_effect(_color:Color, time:float) -> void:
	print("ghost born")
#	if state == myState.ATTACK:
#		# 残像エフェクトを生成判定
#		ghost_cnt += 1
#		if ghost_cnt%6== 2:
#			# 残像エフェクト生成
#			var eft = ghostEffect.instance()
#			eft.start(position, image.scale, image.frame, false, _color, time)
#			get_parent().add_child(eft)
#			get_parent().get_parent().get_node("GhostList").add_child(eft)
	pass

func shockWave_Animation():
	
	get_tree().get_root().get_node("WorldManager").get_node("oneBackGround").start_shockwave(global_position)
	pass
	
class TearIdleState extends StateTemp:
	
	func _enter(m_Owner):
#		print("state:Idle")
		pass
	
	func _execute(m_Owner):
		m_Owner.velocity = m_Owner.velocity.move_toward(Vector2.ZERO, m_Owner.FRICTION * m_Owner.scope_delta)
#		m_Owner.velocity = m_Owner.velocity.move_toward(Vector2.ZERO, m_Owner.stats.Friction * m_Owner.scope_delta)
		
#		if(m_Owner.direction.x > 0):
		if(m_Owner.is_look_right):
			#右向き待機のアニメーション
			m_Owner.play_anim("IdleRight")
			pass
		else:
			#左向き待機のアニメーション
			m_Owner.play_anim("IdleLeft")
			pass

		if m_Owner.playerDetrctionZone.can_see_player():
			m_Owner.player = m_Owner.playerDetrctionZone.player
			
			#ここにchasestateに変更する処理を追加
			if m_Owner.playerDetrctionZone.is_area_target:
				m_Owner.stateMatchine.ChangeState(m_Owner.chaseState)
		else:
			m_Owner.player = null
			pass
		pass
	
	func _exit(m_Owner):
		pass

class TearChaseState extends StateTemp:
	
	func _enter(m_Owner):
#		print("state:Chase")
		pass
	
	func _execute(m_Owner):
		if m_Owner.playerDetrctionZone.is_area_target:
			var distanceData = m_Owner.player.global_position - m_Owner.global_position
			m_Owner.direction = distanceData.normalized()
			m_Owner.velocity = m_Owner.direction
#			print(m_Owner.velocity)
			
			if(m_Owner.direction.x > 0):
				#右向き待機のアニメーション
				m_Owner.play_anim("RunRight")
				m_Owner.is_look_right = true
				pass
			else:
				#左向き待機のアニメーション
				m_Owner.play_anim("RunLeft")
				m_Owner.is_look_right = false
				pass
			
			distanceData = sqrt(pow(distanceData.x, 2) + pow(distanceData.y, 2))
			#もし、playerとの距離が10以下だった場合、stayNearStateに移行する
			if(distanceData < 35):
				m_Owner.stateMatchine.ChangeState(m_Owner.stayNearState)
				return
			else:
				#違う場合には、playerに向かって移動する
#				m_Owner.velocity = m_Owner.velocity.move_toward(m_Owner.velocity * m_Owner.MAX_SPEED, m_Owner.ACCELERATION * m_Owner.scope_delta)
				m_Owner.velocity = m_Owner.velocity.move_toward(m_Owner.velocity * m_Owner.MAX_SPEED, m_Owner.ACCELERATION)
#				m_Owner.velocity = m_Owner.velocity.move_toward(m_Owner.velocity * m_Owner.stats.MaxSpeed, m_Owner.stats.Acceleration)
				
		else:
			m_Owner.stateMatchine.ChangeState(m_Owner.idleState)
	
	func _exit(m_Owner):
		pass
		
class TearStayNearState extends StateTemp:
	
	func _enter(m_Owner):
#		print("state:stayNear")
#		print("on nextAction Timer set!")
		m_Owner.softCollision_col.set_deferred("disabled", true)
		m_Owner.chose_attack()
		pass
	
	func _execute(m_Owner):
#		print(m_Owner.will_attack_class)
		
		m_Owner.velocity = m_Owner.velocity.move_toward(Vector2.ZERO, m_Owner.FRICTION * m_Owner.scope_delta)
#		m_Owner.velocity = m_Owner.velocity.move_toward(Vector2.ZERO, m_Owner.stats.Friction * m_Owner.scope_delta)
		
#		if(m_Owner.direction.x > 0):
		if(m_Owner.is_look_right):
			#右向き待機のアニメーション
			#attackの名前で識別して待機アニメーションを切り替える
			m_Owner.play_anim("IdleRight")
			pass
		else:
			#左向き待機のアニメーション
			#attackの名前で識別して待機アニメーションを切り替える
			m_Owner.play_anim("IdleLeft")
			pass
		pass
	
	func _exit(m_Owner):
		m_Owner.softCollision_col.set_deferred("disabled", false)
		m_Owner.nextActionTimer.stop()
		m_Owner.switch_DuelFlag(false)
		pass

class TearDamageState extends StateTemp:
	
	func _enter(m_Owner):
#		print("state:damage")
		m_Owner.softCollision_col.set_deferred("disabled", true)
		m_Owner.anim.stop(true)
		pass
	
	func _execute(m_Owner):
#		if(m_Owner.direction.x > 0):
		if(m_Owner.is_look_right):
			#右向き待機のアニメーション
			m_Owner.play_anim("DamageRight")
			pass
		else:
			#左向き待機のアニメーション
			m_Owner.play_anim("DamageLeft")
			pass
		pass
	
	func _exit(m_Owner):
		m_Owner.softCollision_col.set_deferred("disabled", false)
		pass


class TearAttackState extends StateTemp:
	
	func _enter(m_Owner):
		m_Owner.softCollision_col.set_deferred("disabled", true)
#		print("state:attack")
		m_Owner.fadeAnimation.set_Animation()
		#各攻撃のノックバックの強さを追加する
#		m_Owner.hitBox.change_Knockback_Pow(150)
		m_Owner.stats.knockback_pow = 150
		m_Owner.stats._float_pow = 0
#		if(m_Owner.direction.x > 0):
		if(m_Owner.is_look_right):
			#右向きアニメーション
			m_Owner.play_anim("AttackRight")
		else:
			#左向きアニメーション
			m_Owner.play_anim("AttackLeft")
		pass
	
	func _execute(m_Owner):
		pass
	
	func _exit(m_Owner):
#		m_Owner.hitBoxCol.set_disabled(true)
		m_Owner.hitBoxCol.set_deferred("disabled", true)
		m_Owner.softCollision_col.set_deferred("disabled", false)
		pass	

class TearDuelStayState extends StateTemp:
	
	func _enter(m_Owner):
		print("state : duelSray")
#		m_Owner.hurtboxCollision.set_disabled(true)
		m_Owner.hurtboxCollision.set_deferred("disabled", true)
		m_Owner.softCollision_col.set_deferred("disabled", true)
		m_Owner.velocity = Vector2.ZERO
		m_Owner.anim.stop(false)
		
#		if(m_Owner.direction.x > 0):
#			#右向き待機のアニメーション
#			m_Owner.anim.play("IdleRight")
#		else:
#			#左向き待機のアニメーション
#			m_Owner.anim.play("IdleLeft")
#		pass
	
	func _execute(m_Owner):
		m_Owner.velocity = Vector2.ZERO
		pass
	
	func _exit(m_Owner):
#		m_Owner.hurtboxCollision.set_disabled(false)
		m_Owner.hurtboxCollision.set_deferred("disabled", false)
		m_Owner.softCollision_col.set_deferred("disabled", false)
		m_Owner.play_anim(m_Owner.now_play_anim)
		pass	

class TearDuel1State extends StateTemp:
	
	func _enter(m_Owner):
		print("duel")
		m_Owner.is_look_right = false
		
		m_Owner.duel_end_animation = "duel_rollAttack_End"
		
		m_Owner.body_col.set_deferred("disabled", true)
#		m_Owner.anim.play("Duel1")
		
		m_Owner.create_attackVector()
#		print(m_Owner.knockback_vector)
#		print("duel :" + str(m_Owner.duel_hitBox))
#		m_Owner.duel_hitBox.change_Knockback_Pow(250)
		m_Owner.stats.knockback_pow = 250
		m_Owner.stats._float_pow = 2
		
		m_Owner.	play_anim("duel_rollAttack")
		pass
	
	func _execute(m_Owner):
		pass
	
	func _exit(m_Owner):
#		var image_pos = m_Owner.image.position
#		m_Owner.image.position = Vector2.ZERO
#		m_Owner.position = image_pos
#		m_Owner.softCollision_col.set_disabled(false)
#		m_Owner.image.visible = false
#		m_Owner.image.set_deferred("visible", true)
#		m_Owner.duel_image.visible = true
#		m_Owner.duel_image.set_deferred("visible", false)
		m_Owner.body_col.set_deferred("disabled", false)
		m_Owner.softCollision_col.set_deferred("disabled", false)
		pass	
		

class TearEX_AttackStayState extends StateTemp:
	
	func _enter(m_Owner):
		print("state : ex_Stay")
#		m_Owner.hurtboxCollision.set_disabled(true)
#		m_Owner.hurtboxCollision.set_deferred("disabled", true)
		m_Owner.hurtboxCollision.set_deferred("disabled", false)
		m_Owner.softCollision_col.set_deferred("disabled", true)
		m_Owner.velocity = Vector2.ZERO
		m_Owner.anim.stop(false)
	
	func _execute(m_Owner):
		m_Owner.velocity = Vector2.ZERO
		pass
	
	func _exit(m_Owner):
#		m_Owner.hurtboxCollision.set_disabled(false)
#		m_Owner.hurtboxCollision.set_deferred("disabled", false)
		m_Owner.softCollision_col.set_deferred("disabled", false)
		m_Owner.play_anim(m_Owner.now_play_anim)
		pass	

class TearDeathState extends StateTemp:
	
	func _enter(m_Owner):
#		if(m_Owner.direction.x > 0):
		if(m_Owner.is_look_right):
			#右向きアニメーション
			m_Owner.play_anim("R_death")
		else:
			#左向きアニメーション
			m_Owner.play_anim("L_death")
		pass
	
	func _execute(m_Owner):
		pass
	
	func _exit(m_Owner):
		pass	
