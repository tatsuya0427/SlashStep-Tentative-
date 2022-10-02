extends Node2D

class_name EnemyStats

#enum CharaType{
#	PLAYER,
#	ENEMY,
#	OBJECT
#}
export(String, FILE, ".*tscn") var enemy_healthUI
export(int) var max_health = 1 setget set_max_health
var health = max_health setget set_health

export (int) var power = 1 setget set_power

#生成したhealthBarClassを格納しておく変数
var healthBarClass

#export (int) var Accelerations
#export (int) var MaxSpeed
#export (int) var Friction

export (GameStats.CharaType) var myType

signal no_health
signal health_changed(value)
signal max_health_changed(value)

func set_max_health(value):
	max_health = value
	self.health = min(health, max_health)
	emit_signal("max_health_changed")

func set_health(value):
	health = value
#	print("set stats health" + str(health))
	emit_signal("health_changed", health)
	if health <= 0:
		emit_signal("no_health")
		
func set_power(value):
	power = value

func set_healthUI(flag:bool):
	healthBarClass.set_visible(flag)
#	if flag:
#		SystemUi.get_enemyHealthUI().setting(self, max_health, health)
#	else:
#		SystemUi.get_enemyHealthUI().disconnect_healthUI()
func deathProcess():
	healthBarClass.enemy_deathProcess()

func _ready():
	self.health = max_health
	healthBarClass = load(enemy_healthUI).instance()
	SystemUi.add_child(healthBarClass)
	healthBarClass.setting(self, max_health, health)
	

	
