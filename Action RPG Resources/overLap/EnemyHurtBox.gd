extends Area2D

#export(bool) var show_hit = true

#const HitEffect = preload("res://Action RPG Resources/Effects/HitEffect.tscn")
export(String, FILE, "*.tscn") var HitEffect

var invincible = false setget set_invincible

onready var timer = $Timer

signal invincibility_started#無敵時間の開始用シグナル
signal invincibility_ended#無敵時間の終了用シグナル

func set_invincible(value):
	invincible = value
	if invincible == true:
		emit_signal("invincibility_started")
	else:
		emit_signal("invincibility_ended")

func start_invincibility(duration):
	self.invincible = true
	timer.start(duration)

func create_hit_effect(poss, effectName):#外部から、アクセスがあったときにhit_effectを作成する
	#if show_hit:
	var effect = load(HitEffect).instance()
	var main = get_tree().current_scene
	main.add_child(effect)
	effect.global_position = poss
	if effectName != "":
		effect._play_effect(effectName)

func _on_Timer_timeout():
	self.invincible = false

func _on_HurtBox_invincibility_started():
#	print("off monitorable")
	set_deferred("monitorable", false)

func _on_HurtBox_invincibility_ended():
#	print("on monitorable")
	set_deferred("monitorable", true)
