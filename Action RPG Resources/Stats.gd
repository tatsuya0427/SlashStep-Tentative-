extends Node2D

class_name Stats

enum CharaType{
	PLAYER,
	ENEMY,
	OBJECT
}

export(int) var max_health = 1 setget set_max_health
var health = max_health setget set_health

export (int) var power = 1 setget set_power

#export (int) var Accelerations
#export (int) var MaxSpeed
#export (int) var Friction

export (CharaType) var myType

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

func _ready():
#	print("------------")
#	print(get_parent())
#	print(str(max_health))
#	print("------------")
	self.health = max_health
