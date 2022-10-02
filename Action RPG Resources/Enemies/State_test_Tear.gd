extends KinematicBody2D

const EnemyDeathEffect = preload("res://Action RPG Resources/Effects/EnemyDeathEffect.tscn")

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

#var state = myState.IDLE
#var stun_before_state = state
#var stun = false#trueなら行動不能

#このキャラクターの移動方向を司る変数
var velocity = Vector2.ZERO
#このキャラクターが吹っ飛ぶ力
var knockback = Vector2.ZERO
#このキャラクターの向いている向き
var direction = Vector2.ZERO


#-----------------追跡関係---------------------
#onready var playerDetrctionZone = $TargetDetectionTemp
onready var playerDetrctionZone = $Image/PlayerDetectionZone
#----------------------------------------------

#--------------アニメーション関係----------------
onready var image = $Image
onready var anim = $AnimationPlayer
#onready var animationSprite = $AnimatedSprite
#onready var tearImage = $TearImage
onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")
#----------------------------------------------
onready var hurtbox = $Image/HurtBox
onready var hurtboxCollision = $Image/HurtBox/CollisionShape2D
onready var softCollision = $Image/SoftCollision
onready var softCollision_col = $Image/SoftCollision/CollisionShape2D

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
onready var targetImage = $Image/Target
onready var pop = $Label

#-------------------------------------------------------

#------------------------攻撃関連------------------------
#攻撃時のふっとばし力
export var knockback_pow = 30
#STAYNEAR状態になった際に、ランダムな秒数後、Playerが近いなら攻撃を行い、遠い場合にはIdle状態になる
onready var nextActionTimer = $NextActionTimer

#knockbackやDamageの値はこのクラスから変更する
onready var hitBox = $Image/HitBoxPivot/HitBox
#攻撃の当たり判定の処理
onready var hitBoxCal = $Image/HitBoxPivot/HitBox/CollisionShape2D
#attackTimerが設定された際にはtrueになり、追加でattackTimerが設定されないようにする
#var will_attack = false

#攻撃内容を格納しておく配列
var attackList = []
#次に行う攻撃Stateを格納する変数
var will_attack_state

#残像を作成するスクリプトの代入
#export var ghostEffect = $GhostEffect
#export(String, FILE, "*.tscn") var ghostEffect
const ghostEffect = preload("res://Action RPG Resources/Effects/TearGhostEffect.tscn")
#攻撃時に残像を作る数
var ghost_cnt = 0

#現在のimageフレームを取得ためのnode
#onready var image = $Image

#攻撃時に赤く光る機能
onready var fadeAnimation = $Image/FadeAnimation

#-----------デュアルシステム関係----------------
#デュアルシステムを起動できる攻撃時に頭上に表示する画像
onready var attentionImage = $Image/AttentionImage
#デュアルシステムを起動できる状態にある場合にはtrueに
onready var duelFlag = false
#onready var tween = get_tree().create_tween()
#onready var tween = $Tween
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
	
#	hitBox.damage = stats.power
	
	targetImage.visible = false
	
	attentionImage.visible = false
	duelFlag = false
	
	softCollision_col.set_disabled(false)
	
	attackList.push_back(attackState)
	attackList.push_back(duel1State)

func _physics_process(delta):
	scope_delta = delta
	
	knockback = knockback.move_toward(Vector2.ZERO, FRICTION * delta)
#	knockback = knockback.move_toward(Vector2.ZERO, stats.Friction * delta)
	
	stateMatchine.Update()
	
	#------------------------------
	if softCollision.is_colliding():#敵同士が重ならないようにする機構
		velocity += softCollision.get_push_vector() * delta * 100
	
	velocity = move_and_slide(velocity)
	knockback = move_and_slide(knockback)
	
	fadeAnimation.view_Effect(image.frame)

#------------------------------

#ターゲットになった場合に、ターゲットカーソルの表示とbool変数に格納
func set_targeting(value):
	targeting = value
	targetImage.visible = value

#デュアルシステムが起動可能か否かを切り替える関数
func switchDuelFlag(flag:bool):
	if flag:
		attentionImage.visible = true
		duelFlag = true
	else:
		attentionImage.visible = false
		duelFlag = false
	pass

func move_duelStage(pos):
	var tween:Tween = Tween.new()
	
	softCollision_col.set_disabled(true)
	tween.interpolate_property(self, "position", position, pos, 0.3, Tween.TRANS_EXPO, Tween.EASE_OUT)
	tween.interpolate_callback(self, 0.3, "move_duelStage_complete")
	
	add_child(tween)
	tween.start()
#	tween.set_ease(Tween.EASE_IN_OUT)
#	tween.set_trans(Tween.TRANS_EXPO)
#	tween.tween_property (self, "position", pos, 0.5)
#	tween.tween_callback(self, "move_duelStage_complete")
#	tween.play()
	pass
	
func move_duelStage_complete():
	print("move completed")
	anim.play("IdleLeft")
	stateMatchine.ChangeState(duel1State)
	pass

#次の攻撃をランダムに選択する
func chose_attack():
	#ここでランダムに攻撃パターンを選択する
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	#ここの乱数の最大値は攻撃パターンを配列にして上限を変更できるように後々修正
	#duelなら、頭上に！を表示する
	will_attack_state = attackList[rng.randi_range(0, attackList.size() - 1)]
	if will_attack_state.is_duel:
		switchDuelFlag(true)
	nextActionTimer.start(rand_range(0.3, 1.5))

func _on_NextActionTimer_timeout():
	if duelFlag:
		switchDuelFlag(false)
	
	if playerDetrctionZone.can_see_player():
		var distanceData = (player.global_position - global_position).normalized()
		var correction_knockback_vector = Vector2.ZERO
		correction_knockback_vector.x = distanceData.x / sqrt(pow(distanceData.x, 2) + pow(distanceData.y, 2))
		correction_knockback_vector.y = distanceData.y / sqrt(pow(distanceData.x, 2) + pow(distanceData.y, 2))
		hitBox.knockback_vector = correction_knockback_vector
		
#		stateMatchine.ChangeState(will_attack_state)
		stateMatchine.ChangeState(will_attack_state)
		
	else:
		stateMatchine.ChangeState(idleState)
	pass # Replace with function body.

#---------------------ダメージ＋怯み関係------------------------
func _on_HurtBox_area_entered(area):
	print("damage!")
	print("- - - - -")
	velocity = Vector2.ZERO
	stats.health -= area.damage
	knockback = area.knockback_vector * area.knockback_pow
	hurtbox.create_hit_effect(global_position)
	stateMatchine.ChangeState(damageState)
	anim.stop(true)
	
#-------------------------------------------------------
	
func _on_Stats_no_health():
	_proc_ghost_effect(Color(255, 255, 255, 255), 1.0)
	var enemyDeathEffect = EnemyDeathEffect.instance()
	get_parent().add_child(enemyDeathEffect)
	enemyDeathEffect.global_position = global_position
	
	#もし、target自身がターゲットされている場合、別の一番近い的をターゲットするための処理をさせる。
#	if targeting:
#		get_parent().get_ClosestTarget_fromPlayer()
#		pass
	
	#もし、waveEnemyの場合、死亡時にwaveManagerでカウントする信号を送る
	if(do_connect_wave):
		GameStats.set_Score(enemy_Score)
		emit_signal("death")
	queue_free()

func attack_Animation_Finish():
	stateMatchine.ChangeState(idleState)
	pass
	
func damage_animation_Finish():
#	state = IDLE
#	change_State(myState.IDLE)
#	next_DamageFlag = false
#	animatedSprite.visible = false
#	tearImage.visible = true
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
	print("shoc!")
	get_tree().get_root().get_node("WorldManager").get_node("oneBackGround").start_shockwave(global_position)
	pass
	
class TearIdleState extends StateTemp:
	var is_duel = false
	
	func _enter(m_Owner):
#		print("state:Idle")
		pass
	
	func _execute(m_Owner):
		m_Owner.velocity = m_Owner.velocity.move_toward(Vector2.ZERO, m_Owner.FRICTION * m_Owner.scope_delta)
#		m_Owner.velocity = m_Owner.velocity.move_toward(Vector2.ZERO, m_Owner.stats.Friction * m_Owner.scope_delta)
		
		if(m_Owner.direction.x > 0):
			#右向き待機のアニメーション
			m_Owner.anim.play("IdleRight")
			pass
		else:
			#左向き待機のアニメーション
			m_Owner.anim.play("IdleLeft")
			pass

		if m_Owner.playerDetrctionZone.can_see_player():
			m_Owner.player = m_Owner.playerDetrctionZone.player
			
			#ここにchasestateに変更する処理を追加
			m_Owner.stateMatchine.ChangeState(m_Owner.chaseState)
		else:
			m_Owner.player = null
			pass
		pass
	
	func _exit(m_Owner):
		pass

class TearChaseState extends StateTemp:
	var is_duel = false
	
	func _enter(m_Owner):
#		print("state:Chase")
		pass
	
	func _execute(m_Owner):
		if m_Owner.playerDetrctionZone.player != null:
			var distanceData = m_Owner.player.global_position - m_Owner.global_position
			m_Owner.direction = distanceData.normalized()
			m_Owner.velocity = m_Owner.direction
#			print(m_Owner.velocity)
			
			if(m_Owner.direction.x > 0):
				#右向き待機のアニメーション
				m_Owner.anim.play("RunRight")
				pass
			else:
				#左向き待機のアニメーション
				m_Owner.anim.play("RunLeft")
				pass
			
			distanceData = sqrt(pow(distanceData.x, 2) + pow(distanceData.y, 2))
			#もし、playerとの距離が10以下だった場合、stayNearStateに移行する
			if(distanceData < 40):
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
	var is_duel = false
	
	func _enter(m_Owner):
#		print("state:stayNear")
#		print("on nextAction Timer set!")
		m_Owner.chose_attack()
		pass
	
	func _execute(m_Owner):
		m_Owner.velocity = m_Owner.velocity.move_toward(Vector2.ZERO, m_Owner.FRICTION * m_Owner.scope_delta)
#		m_Owner.velocity = m_Owner.velocity.move_toward(Vector2.ZERO, m_Owner.stats.Friction * m_Owner.scope_delta)
		
		if(m_Owner.direction.x > 0):
			#右向き待機のアニメーション
			#attackの名前で識別して待機アニメーションを切り替える
			m_Owner.anim.play("IdleRight")
			pass
		else:
			#左向き待機のアニメーション
			#attackの名前で識別して待機アニメーションを切り替える
			m_Owner.anim.play("IdleLeft")
			pass
		pass
	
	func _exit(m_Owner):
		m_Owner.nextActionTimer.stop()
		m_Owner.switchDuelFlag(false)
		pass

class TearDamageState extends StateTemp:
	var is_duel = false
	
	func _enter(m_Owner):
#		print("state:damage")
		pass
	
	func _execute(m_Owner):
		if(m_Owner.direction.x > 0):
			#右向き待機のアニメーション
			m_Owner.anim.play("DamageRight")
			pass
		else:
			#左向き待機のアニメーション
			m_Owner.anim.play("DamageLeft")
			pass
		pass
	
	func _exit(m_Owner):
		pass


class TearAttackState extends StateTemp:
	var is_duel = false
	
	func _enter(m_Owner):
#		print("state:attack")
		m_Owner.fadeAnimation.set_Animation()
		#各攻撃のノックバックの強さを追加する
		m_Owner.hitBox.change_Knockback_Pow(150)
		
		if(m_Owner.direction.x > 0):
			#右向きアニメーション
			m_Owner.anim.play("AttackRight")
		else:
			#左向きアニメーション
			m_Owner.anim.play("AttackLeft")
		pass
	
	func _execute(m_Owner):
		pass
	
	func _exit(m_Owner):
		m_Owner.hitBoxCal.set_disabled(true)
		pass	

class TearDuelStayState extends StateTemp:
	var is_duel = false
	
	func _enter(m_Owner):
		print("state : duelSray")
		m_Owner.hurtboxCollision.set_disabled(true)
		
		if(m_Owner.direction.x > 0):
			#右向き待機のアニメーション
			m_Owner.anim.play("IdleRight")
		else:
			#左向き待機のアニメーション
			m_Owner.anim.play("IdleLeft")
		pass
	
	func _execute(m_Owner):
		pass
	
	func _exit(m_Owner):
		m_Owner.hurtboxCollision.set_disabled(false)
		pass	

class TearDuel1State extends StateTemp:
	var is_duel = true
	
	func hoge():
		print("tween completed")
		
	
	func _enter(m_Owner):
		m_Owner.anim.play("Duel1")
#		var buckStep = m_Owner.position
#		buckStep.x += 10
#		var charge = m_Owner.position
#		charge.x -= 100
		
#		var t = Tween.new()
#
##		tween.stop_all()
#		t.interpolate_property(self, "position", m_Owner.position, buckStep, 0.3, Tween.TRANS_EXPO, Tween.EASE_OUT)
#		t.interpolate_property(self, "position", m_Owner.position, m_Owner.position, 0,3, Tween.TRANS_EXPO, Tween.EASE_OUT)
#		t.interpolate_property(self, "position", m_Owner.position, charge, 0,5, Tween.TRANS_EXPO, Tween.EASE_OUT)
#		t.interpolate_callback(self, 1.1, "hoge")
#		add_child(t)
#
#		t.start()
		
#		m_Owner.tween.set_ease(Tween.EASE_IN_OUT)
#		m_Owner.tween.set_trans(Tween.TRANS_EXPO)
#		m_Owner.tween.tween_property (m_Owner, "position", buckStep, 0.5)
#		m_Owner.tween.tween_interval(0.5)
#		m_Owner.tween.tween_property (m_Owner, "position", charge, 0.5)
#		m_Owner.tween.play()
	
	func _execute(m_Owner):
		pass
	
	func _exit(m_Owner):
		m_Owner.softCollision_col.set_disabled(false)
		pass	

