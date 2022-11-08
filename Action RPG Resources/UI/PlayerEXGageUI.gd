extends Control

#class_name PlayerHealthUI

var ex_point = 0 setget set_ex
var max_ex_point = 0 setget set_max_ex


#HP現象effectが終了時に上限値を更新して保存しておく変数
#var effect_health = 0

onready var EXBar_over = $surplusEXBar
onready var EXBar_under = $EXUnder
#onready var healthBar_effect = $HealthRedEffect
#onready var update_tween = $UpdateTween

#connnect時に、接続したstatsクラスを保存しておき、target変更時or撃破時にdisconnectするための変数
var beforeConnect_statsClass = null

func set_ex(value):
#	print("change health")
#	print(value)
	print(value)
	ex_point = clamp(0, value, max_ex_point)#上限下限の設定
	print("set ex " + str(ex_point))
	EXBar_over.value = ex_point
#	if heartUIFull != null:
#		heartUIFull.rect_size.x = hearts * 15
#	if healthBar_over != null:
#		print("change health!!!!")
#		print(hearts)
#	update_tween.stop_all()

#	healthBar_effect.value = effect_health
#	print("effect_health " + str(effect_health))
#	update_tween.interpolate_property(healthBar_under, "value", healthBar_under.value, value - 1, 0.4, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0.4)
#	update_tween.interpolate_property(healthBar_effect, "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0), 1.0, Tween.TRANS_LINEAR, Tween.EASE_IN)
#
#	update_tween.interpolate_callback(self, 1.0, "healthEffect_completed")
#
#	update_tween.start()
#	print("over " + str(healthBar_over.value))
#	print("under " + str(healthBar_under.value))
	pass
		
#func healthEffect_completed():
#	effect_health = healthBar_over.value
##	print("change effect_health " + str())
#	pass


func set_max_ex(value):
#	print("change max health")
	max_ex_point = max(value, 1)
	self.ex_point = min(ex_point, max_ex_point)
	if EXBar_over != null:
		EXBar_over.max_value = value
		EXBar_under.max_value = value
#		PlayerStats.max_health = value

func setting(statsClass, max_ex, ex):
#	healthBar_over = $surplusHealthBar
#	healthBar_under = $HealthUnder
	
	print("setting player health ui")
	
#	healthBar_over.min_value = 0
#	print(max_health)
	
	EXBar_over.max_value = max_ex
	EXBar_over.value = ex

#	healthBar_under.min_value = 0
	EXBar_under.max_value = max_ex
	EXBar_under.value = ex
	
#	effect_health = health
	
	statsClass.connect("ex_changed", self, "set_ex")
	statsClass.connect("max_ex_changed", self, "set_max_ex")
	
	set_visible(true)
	
#	beforeConnect_statsClass = statsClass
#	print(healthBar_under.max_value)
#	print(healthBar_under.value)
	pass

func set_visible(flag:bool):
	EXBar_over.visible = flag
	EXBar_under.visible = flag
	pass

#func disconnect_healthUI():
#	if beforeConnect_statsClass != null:
#		beforeConnect_statsClass.disconnect("health_changed", self, "set_hearts")
#		beforeConnect_statsClass.disconnect("max_health_changed", self, "set_max_hearts")
#		beforeConnect_statsClass = null

func _ready():
#	print("health ready")
	
#	self.max_hearts = PlayerStats.max_health
#	self.hearts = PlayerStats.health

#	set_max_hearts(PlayerStats.max_health)


#	PlayerStats.connect("health_changed", self, "set_hearts")
#	PlayerStats.connect("max_health_changed", self, "set_max_hearts")
	
	#HPバーの設定↓
#	healthBar.visible = false
#	healthBar_over.min_value = 0
#	healthBar_over.max_value = PlayerStats.max_health
#	healthBar_over.value = PlayerStats.health
#
#	healthBar_under.min_value = 0
#	healthBar_under.max_value = PlayerStats.max_health
#	healthBar_under.value = PlayerStats.health
	pass
