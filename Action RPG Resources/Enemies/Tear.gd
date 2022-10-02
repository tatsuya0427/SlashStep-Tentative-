extends KinematicBody2D

const EnemyDeathEffect = preload("res://Action RPG Resources/Effects/EnemyDeathEffect.tscn")

#------------------------------で囲んだところ以外はインスタンス化できそう。動画見終わったらそれをやってオリジナルのてきに適用しよう


#-------------移動速度関係----------------
export var ACCELERATION = 300
export var MAX_SPEED = 50
export var FRICTION = 200
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
var stateMatchine = null

#各状態のステート内容を格納する変数
var idleState
var chaseState
var stayNearState
var attackState
var damageState

var state = myState.IDLE
var stun_before_state = state
var stun = false#trueなら行動不能

#このキャラクターの移動方向を司る変数
var velocity = Vector2.ZERO

#------------------------------

var knockback = Vector2.ZERO

onready var stats = $Stats

#onready var playerDetrctionZone = $TargetDetectionTemp
onready var playerDetrctionZone = $PlayerDetectionZone
#onready var animationSprite = $AnimatedSprite
#onready var tearImage = $TearImage
onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")

onready var hurtbox = $HurtBox
onready var softCollision = $SoftCollision

#------------------------怯み関係------------------------
#攻撃を受けてから、敵が再び動けるようになるまでのタイマー
onready var stunTimer = $STUNTimer
#ダメージ中にダメージを受けた時にtrueにし、ダメージアニメーションをリセットする関数を起動する
var next_DamageFlag = false
#-------------------------------------------------------

#------------------------追跡関係------------------------
var player = null
var direction = Vector2.ZERO
#-------------------------------------------------------

#------------------------攻撃関連------------------------
#攻撃力
export var power = 1
#攻撃時のふっとばし力
export var knockback_pow = 30
#STAYNEAR状態になった際に、ランダムな秒数後攻撃を行う。
onready var attackTimer = $AttackTimer
#knockbackやDamageの値はこのクラスから変更する
onready var hitBox = $HitBoxPivot/HitBox
#attackTimerが設定された際にはtrueになり、追加でattackTimerが設定されないようにする
var will_attack = false

#myState = Attackの時に行う技種類
enum attackType{
	TEAR,
	CHARGE,
}
#attackTypeを格納する変数
var selectAttackType = attackType.TEAR

#残像を作成するスクリプトの代入
#export var ghostEffect = $GhostEffect
#export(String, FILE, "*.tscn") var ghostEffect
const ghostEffect = preload("res://Action RPG Resources/Effects/TearGhostEffect.tscn")
#攻撃時に残像を作る数
var ghost_cnt = 0
#現在のimageフレームを取得ためのnode
onready var image = $Image
#攻撃時に赤く光る機能
onready var fadeAnimation = $FadeAnimation
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
	idleState = TearIdleState.new()
#	chaseState = 
#	stayNearState = 
#	attackState = 
#	damageState = 
	stateMatchine = StateMatchine.new(idleState)
	pass

#waveの時に生成される敵にはこの関数を実行
func set_WaveEnemy():
#	waveManager.connect("destroySignal", waveManager, "destroy_Wave_Enemy")
	do_connect_wave = true
	#敵生成アニメーションを作成
	
func set_StateParameters(type, value):
	match type:
		"power":
			hitBox.damage = value
		"knockback_power":
			hitBox.knockback_pow = value
			
func _ready():
#	$HitBoxPivot/HitBox/CollisionShape2D.disabled = true
	animationTree.active = true
	attackTimer.one_shot = true
#	if():
	set_StateParameters("power", power)

func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO, FRICTION * delta)
	knockback = move_and_slide(knockback)

#------------------------------
	match state:
		myState.IDLE:
			idle_State(delta)
		myState.WANDER:
			pass
		myState.CHASE:
			Chase_state(delta)
		myState.STAYNEAR:
			staynear_State()
		myState.ATTACK:
			attack_State()
		myState.DAMAGE:
			damage_State()
			
	if softCollision.is_colliding():#敵同士が重ならないようにする機構
		velocity += softCollision.get_push_vector() * delta * 400
	
	if(stun):
		velocity = Vector2.ZERO
	
	velocity = move_and_slide(velocity)
	
	fadeAnimation.view_Effect(image.frame)

func change_State(afterState):
	if !stun || afterState == myState.DAMAGE || afterState == myState.IDLE:
		state = afterState
		
		if(state == myState.ATTACK):
			fadeAnimation.set_Animation()
#			fadeAnimation.set_animation(Color(219 / 255, 9 / 255, 9 / 255, 95 / 255), 1.0, 1)
	

func seek_player():
	if playerDetrctionZone.can_see_player() && state != myState.STAYNEAR:
#		state = CHASE
		change_State(myState.CHASE)

#------------------------------
func idle_State(delta):
	velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	animationTree.set("parameters/Idle/blend_position", direction)
	animationState.travel("Idle")
	seek_player()

func Chase_state(delta):
	player = playerDetrctionZone.player
	direction = Vector2.ZERO
	if player != null:
		direction = (player.global_position - global_position).normalized()
#		print("direc :" + str(direction))
		velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta)
#		print("veloc :" + str(velocity))
		animationTree.set("parameters/Run/blend_position", direction)
		animationState.travel("Run")
		
		#攻撃時、相手の吹っ飛ばし方向の更新
#		if(velocity.x > 0):
#			hitBox.knockback_vector.x = 1
#		else:
#			hitBox.knockback_vector.x = -1
#
#		if(velocity.y > 0):
#			hitBox.knockback_vector.y = 1
#		else:
#			hitBox.knockback_vector.y = -1
		
	else:
#		state = IDLE
		change_State(myState.IDLE)
		animationTree.set("parameters/Idle/blend_position", direction)
		animationState.travel("Idle")
#			animationSprite.flip_h = velocity.x < 0


func staynear_State():
	velocity = Vector2.ZERO
	animationTree.set("parameters/Idle/blend_position", direction)
	animationState.travel("Idle")
	if !will_attack:
		attackTimer.start(rand_range(0.3, 1.5))
		will_attack = true
	pass

func _on_AttackTimer_timeout():
	#攻撃時、相手の吹っ飛ばし方向の更新
#	var correction_knockback_vector = velocity
#	correction_knockback_vector.x = velocity.x / sqrt(pow(velocity.x, 2) + pow(velocity.y, 2))
#	correction_knockback_vector.y = velocity.y / sqrt(pow(velocity.x, 2) + pow(velocity.y, 2))
	hitBox.knockback_vector = direction
	
	change_State(myState.ATTACK)

func attack_State():
	velocity = Vector2.ZERO
	hitBox.change_Knockback_Pow(knockback_pow)
	animationTree.set("parameters/Attack/blend_position", direction)
	animationState.travel("Attack")
	
	#特定の攻撃で残像を出したい時にはこの関数を含めること
#	_proc_ghost_effect()
	
func damage_State():
#	velocity = Vector2.ZERO
	animationTree.set("parameters/nextDamage/blend_position", direction)
	animationTree.set("parameters/Damage/blend_position", direction)
#	if(next_DamageFlag):
#		animationState.travel("nextDamage")
#	else:
#		animationState.travel("Damage")
#	pass

	animationState.travel("Damage")

#---------------------ダメージ＋怯み関係------------------------
func _on_HurtBox_area_entered(area):
	stats.health -= area.damage
	knockback = area.knockback_vector * area.knockback_pow
	hurtbox.create_hit_effect(global_position)
#	change_State(STUN)
#	animatedSprite.visible = true
#	animatedSprite.play("DamageR")
#	tearImage.visible = false
#	state = DAMAGE
	if(state == myState.DAMAGE):
		next_DamageFlag = true
#		print(animationState.is_playing())
#		animationState.start("Damage")
#		$AnimationPlayer.stop(true)
	change_State(myState.DAMAGE)
	stun = true
	stunTimer.start(2)
#-------------------------------------------------------
	
func _on_Stats_no_health():
	_proc_ghost_effect(Color(255, 255, 255, 255), 1.0)
	var enemyDeathEffect = EnemyDeathEffect.instance()
	get_parent().add_child(enemyDeathEffect)
	enemyDeathEffect.global_position = global_position
	
	#もし、waveEnemyの場合、死亡時にwaveManagerでカウントする信号を送る
	if(do_connect_wave):
		GameStats.set_Score(enemy_Score)
		emit_signal("death")
	
	queue_free()

#playerの側まで移動してきたら攻撃が当たる箇所でとどまる
func _on_StayPosition_body_entered(body):
#	change_State(STAYNEAR)
	if(state != myState.ATTACK):
#		state = STAYNEAR
		change_State(myState.STAYNEAR)
	pass # Replace with function body.

#playerが離れた際に、攻撃モーション中以外だったら通常状態に戻る
func _on_StayPosition_body_exited(body):
#	change_State(IDLE)
	if(state != myState.ATTACK):
#		state = IDLE
		change_State(myState.IDLE)

func attack_Animation_Finish():
#	state = IDLE
	change_State(myState.IDLE)
	will_attack = false
#	shockWave_Animation()
	
func damage_animation_Finish():
#	state = IDLE
	change_State(myState.IDLE)
	next_DamageFlag = false
#	animatedSprite.visible = false
#	tearImage.visible = true

#スタンの時間解除
func _on_STUNTimer_timeout():
	stun = false

# 残像エフェクトの処理	
func _proc_ghost_effect(_color:Color, time:float) -> void:
	print("ghost born")
	if state == myState.ATTACK:
		# 残像エフェクトを生成判定
		ghost_cnt += 1
		if ghost_cnt%6== 2:
			# 残像エフェクト生成
			var eft = ghostEffect.instance()
			eft.start(position, image.scale, image.frame, false, _color, time)
#			get_parent().add_child(eft)
			get_parent().get_parent().get_node("GhostList").add_child(eft)

func shockWave_Animation():
	print("shoc!")
	get_tree().get_root().get_node("WorldManager").get_node("oneBackGround").start_shockwave(global_position)
	pass


	
class TearIdleState extends StateTemp:
		
	
	func _enter(m_Owner):
		pass
	
	func _execute(m_Owner):
#		var velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
#		animationTree.set("parameters/Idle/blend_position", direction)
#		animationState.travel("Idle")
#		seek_player()
#		return velocity
		pass
	
	func _exit(m_Owner):
		pass
