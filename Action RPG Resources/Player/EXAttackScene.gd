extends Node2D

#animation再生
onready var anim = $ex_attack_anim
#現在再生中のアニメーションを保持
var now_play_anim : String = ""
#演出中にボタンを押した回数を保存
var charge_value = 0
#このシーンを呼び出したクラスを保存しておく
var _client = null
#このシーンで当たり判定を出した時に参照されるplayer.statsを呼び出された時に保存しておく
var _stats = null

func _ready():
	visible = false
#	_start_ex_attack()
	pass # Replace with function body.

func _play_anim(target:String):
	now_play_anim = target
	visible = true
	anim.play(target)

func _start_ex_attack(client, stats):
	_client = client
	_stats = stats
	_play_anim("ex_attack_ready")
	
func _physics_process(delta):
	#現在再生されているアニメーションごとに入力捜査の受付や処理を変更
	match now_play_anim:
		"ex_attack_ready":
			if Input.is_action_just_pressed("action"):
				_play_anim("ex_attack_chargeReady")
			pass
		"ex_attack_chargeL1":
			if Input.is_action_just_pressed("action"):
				charge_value += 1
				
			if charge_value > 10:
				_play_anim("ex_attack_chargeL2")
			pass
		"ex_attack_chargeL2":
			if Input.is_action_just_pressed("action"):
				charge_value += 1
				
			if charge_value > 20:
				_play_anim("ex_attack_chargeL3")
			pass	
		"ex_attack_chargeL3":
			if Input.is_action_just_pressed("action"):
				charge_value += 1
				
			if charge_value > 30:
				_play_anim("ex_attack")
				charge_value = 0
			pass

func _ex_attack_chargeReady_finished():
	_play_anim("ex_attack_chargeL1")

func _ex_attack_finished():
	_client.end_EXAttack()
