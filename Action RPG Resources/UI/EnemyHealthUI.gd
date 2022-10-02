extends Control

#class_name PlayerHealthUI

var hearts = 0 setget set_hearts
var max_hearts = 0 setget set_max_hearts

#HP現象effectが終了時に上限値を更新して保存しておく変数
var effect_health = 0

onready var healthBar_over = $surplusHealthBar
onready var healthBar_under = $HealthUnder
onready var healthBar_effect = $HealthRedEffect
onready var update_tween = $UpdateTween

#connnect時に、接続したstatsクラスを保存しておき、target変更時or撃破時にdisconnectするための変数
var beforeConnect_statsClass = null

func set_hearts(value):
#	print("change health")
#	print(value)
	hearts = clamp(value, 0, max_hearts)#上限下限の設定
#	if heartUIFull != null:
#		heartUIFull.rect_size.x = hearts * 15
#	if healthBar_over != null:
#		print("change health!!!!")
#		print(hearts)
	update_tween.stop_all()
	healthBar_over.value = value
	healthBar_effect.value = effect_health
#	print(effect_health)
#	print("effect_health " + str(effect_health))
#	update_tween.interpolate_property(healthBar_under, "value", healthBar_under.value, value - 1, 0.4, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0.4)
	update_tween.interpolate_property(healthBar_effect, "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0), 1.0, Tween.TRANS_LINEAR, Tween.EASE_IN)
	
	update_tween.interpolate_callback(self, 1.0, "healthEffect_completed")
	
	update_tween.start()
#	print("over " + str(healthBar_over.value))
#	print("under " + str(healthBar_under.value))
	pass
		
func healthEffect_completed():
	effect_health = healthBar_over.value
#	print("change effect_health " + str(effect_health))
	pass


func set_max_hearts(value):
#	print("change max health")
	max_hearts = max(value, 1)
	self.hearts = min(hearts, max_hearts)
	if healthBar_over != null:
		healthBar_over.max_value = value
		healthBar_under.max_value = value
#		PlayerStats.max_health = value

func setting(statsClass, max_health, health):
#	healthBar_over = $surplusHealthBar
#	healthBar_under = $HealthUnder
	
#	print("setting enemy health ui")
	
#	healthBar_over.min_value = 0
#	print(max_health)
	
	healthBar_over.max_value = max_health
	healthBar_over.value = health

#	healthBar_under.min_value = 0
	healthBar_effect.max_value = max_health
	healthBar_effect.value = health
	
	effect_health = health
	
	statsClass.connect("health_changed", self, "set_hearts")
	statsClass.connect("max_health_changed", self, "set_max_hearts")
	
	beforeConnect_statsClass = statsClass
	set_visible(true)
#	print(healthBar_under.max_value)
#	print(healthBar_under.value)
	pass

func set_visible(flag:bool):
	healthBar_over.visible = flag
	healthBar_under.visible = flag
	healthBar_effect.visible = flag
	pass

func enemy_deathProcess():
	queue_free()

func disconnect_healthUI():
	if beforeConnect_statsClass != null:
		beforeConnect_statsClass.disconnect("health_changed", self, "set_hearts")
		beforeConnect_statsClass.disconnect("max_health_changed", self, "set_max_hearts")
		beforeConnect_statsClass = null
		

func _ready():
	pass
