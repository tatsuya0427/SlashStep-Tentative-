extends Node2D

class_name PlayerStats

#enum CharaType{
#	PLAYER,
#	ENEMY,
#	OBJECT
#}
#export(String, FILE, ".*tscn") var player_healthUI
onready var player_healthUI = load("res://Action RPG Resources/UI/PlayerHealthUI.tscn")
export(int) var max_health = 1 setget set_max_health
var health = max_health setget set_health

onready var player_exhUI = load("res://Action RPG Resources/UI/PlayerEXGageUI.tscn")
export(int) var max_ex_point = 1 setget set_max_ex
var ex_point = 0 setget set_ex

export (int) var power = 1 setget set_power

#生成したhealthBarClassを格納しておく変数
var healthBarClass

var exBarClass
#export (int) var Accelerations
#export (int) var MaxSpeed
#export (int) var Friction

#onready var healthUI = $HealthUI

export (GameStats.CharaType) var myType

signal no_health
signal health_changed(value)
signal max_health_changed(value)

signal ex_changed(value)
signal max_ex_changed(value)

func set_max_health(value):
	max_health = value
	self.health = min(health, max_health)
	emit_signal("max_health_changed", max_health)

func set_health(value):
	health = value
#	print("set stats health" + str(health))
	emit_signal("health_changed", health)
	if health <= 0:
		emit_signal("no_health")
		
func set_max_ex(value):
	max_ex_point = value
	self.ex_point = min(ex_point, max_ex_point)
	emit_signal("max_ex_changed", max_ex_point)

func set_ex(value):
	ex_point = value
	print("ex " + str(ex_point))
#	print("set stats health" + str(health))
	emit_signal("ex_changed", ex_point)
		
func set_power(value):
	power = value

func _ready():
	print("------------")
	print(get_parent())
	print(str(max_health))
	print("------------")
	self.health = max_health
	print(max_health)
	
#	PlayerHealthUi.setting(self, max_health)
#	SystemUi.get_playerHealthUI().setting(self, max_health, health)
#	PlayerHealthUi.max_hearts = max_health
#	PlayerHealthUi.hearts = max_health

	print("hogehoge")
	print(player_healthUI)
	print("hogehoge")
#	healthBarClass = load(player_healthUI).instance()
	healthBarClass = player_healthUI.instance()
	SystemUi.add_child(healthBarClass)
	healthBarClass.setting(self, max_health, health)
	
	exBarClass = player_exhUI.instance()
	SystemUi.add_child(exBarClass)
	exBarClass.setting(self, max_ex_point, ex_point)
#	healthBarClass = SystemUi.get_playerHealthUI()
#	healthBarClass.setting(self, max_health, health)
#	SystemUi.get_playerHealthUI().setting(self, max_health, health)
	
	
#	healthUI.setting(max_health)
