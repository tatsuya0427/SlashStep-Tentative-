extends KinematicBody2D

const EnemyDeathEffect = preload("res://Action RPG Resources/Effects/EnemyDeathEffect.tscn")

#------------------------------で囲んだところ以外はインスタンス化できそう。動画見終わったらそれをやってオリジナルのてきに適用しよう


#------------------------------

export var ACCELERATION = 300
export var MAX_SPEED = 50
export var FRICTION = 200

enum {
	IDLE,
	WANDER,
	CHASE,
	STAYNEAR,
	STUN
}

var state = IDLE
var stun_before_state = state
var velocity = Vector2.ZERO

#------------------------------

var knockback = Vector2.ZERO

onready var stats = $Stats
#onready var playerDetrctionZone = $TargetDetectionTemp
onready var playerDetrctionZone = $PlayerDetectionZone
onready var animationSprite = $AnimatedSprite
onready var hurtbox = $HurtBox
onready var softCollision = $SoftCollision

#攻撃を受けてから、敵が再び動けるようになるまでのタイマー
onready var stunTimer = $STUNTimer

func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO, FRICTION * delta)
	knockback = move_and_slide(knockback)

#------------------------------
	match state:
		IDLE:
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
			seek_player()
			
		WANDER:
			pass
		
		CHASE:
			var player = playerDetrctionZone.player
			if player != null:
				var direction = (player.global_position - global_position).normalized()
				velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta)
			else:
				change_State(IDLE)
			animationSprite.flip_h = velocity.x < 0
			
		STAYNEAR:
			velocity = Vector2.ZERO
			pass
		
		STUN:
			velocity = Vector2.ZERO
			pass
			
	if softCollision.is_colliding():#敵同士が重ならないようにする機構
		velocity += softCollision.get_push_vector() * delta * 400
	
	velocity = move_and_slide(velocity)

func change_State(after_state):
	if state != STUN || after_state == STUN:
		stun_before_state = state
		state = after_state
	else:
		state = after_state
	pass

#STUNTimerもしくは強制反撃(未実装)のみで使用
func release_STUN():
	state = IDLE
	print("release stun")

func seek_player():
#	print(playerDetrctionZone.can_see_target())
#	if playerDetrctionZone.can_see_target():
	if playerDetrctionZone.can_see_player() && state != STAYNEAR:
		change_State(CHASE)
		pass

#------------------------------

func _on_HurtBox_area_entered(area):
	stats.health -= area.damage
	knockback = area.knockback_vector * area.knockback_pow
	hurtbox.create_hit_effect(global_position)
	change_State(STUN)
	stunTimer.start(2)
	
func _on_Stats_no_health():
	queue_free()
	var enemyDeathEffect = EnemyDeathEffect.instance()
	get_parent().add_child(enemyDeathEffect)
	enemyDeathEffect.global_position = global_position


func _on_StayPosition_body_entered(body):
	change_State(STAYNEAR)
	pass # Replace with function body.

func _on_StayPosition_body_exited(body):
	change_State(IDLE)

#スタンの時間解除
func _on_STUNTimer_timeout():
	release_STUN()
