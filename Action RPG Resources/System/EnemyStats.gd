extends Node2D

class_name EnemyStats

#enum CharaType{
#	PLAYER,
#	ENEMY,
#	OBJECT
#}

enum Float_type{
	NONE,
	SMALL,
	MEDIUM,
	LARGE
}

export(String, FILE, ".*tscn") var _enemy_healthUI
export(int) var _max_health = 1 setget set_max_health, get_max_health
var _health = _max_health setget set_health, get_health

export (Float_type) var _hurt_float_pow = Float_type.NONE setget set_hurt_float_pow, get_hurt_float_pow
export (Float_type) var _float_pow = Float_type.NONE setget set_float_pow, get_float_pow

export (int) var _power = 1 setget set_power, get_power
var knockback_vector = Vector2.ZERO
var knockback_pow = 0
#--------ジャンプ、吹っ飛び関係-------------
onready var _jump_move_class = $"../jump_move"

#ジャンプする際に参照する値
export var _jump_height : float setget set_jump_height
export var _jump_time_to_peak : float setget set_jump_time_to_peak
export var _jump_time_to_descent : float setget set_jump_time_to_descent

#吹き飛ばしの際に参照する値
var _float_height : float setget set_float_height
var _float_time_to_peak : float setget set_float_time_to_peak
var _float_time_to_descent : float setget set_float_time_to_descent
#----------------------------------------

#-----------攻撃時に再生するeffect---------
var target_effect : String = "" setget _set_effect
#----------------------------------------

#生成したhealthBarClassを格納しておく変数
var _healthBarClass

#export (int) var Accelerations
#export (int) var MaxSpeed
#export (int) var Friction

export (GameStats.CharaType) var myType

signal no_health
signal health_changed(value)
signal max_health_changed(value)

func set_max_health(value):
	_max_health = value
	self._health = min(_health, _max_health)
	emit_signal("max_health_changed")

func get_max_health():
	return _max_health

func set_health(value):
	_health = value
#	print("set stats health" + str(health))
	emit_signal("health_changed", _health)
	if _health <= 0:
		emit_signal("no_health")

func get_health():
	return _health
		
func set_power(value):
	_power = value

func get_power():
	return _power

func set_hurt_float_pow(value):
	_hurt_float_pow = value
	match _hurt_float_pow:
		Float_type.NONE:
#			_jump_move_class._jump_height = 0.0
#			_jump_move_class._jump_time_to_peak = 0.0
#			_jump_move_class._jump_time_to_descent = 0.0
			pass
		Float_type.SMALL:
			print("change float pow")
			_float_height = 10.0
			_float_time_to_peak = 0.2
#			_float_time_to_descent = 0.3
			_float_time_to_descent = 0.5
			_jump_move_class.floated(_float_height, _float_time_to_peak, _float_time_to_descent)
		Float_type.MEDIUM:
			_float_height = 20.0
			_float_time_to_peak = 0.3
#			_float_time_to_descent = 0.4
			_float_time_to_descent = 0.5
			_jump_move_class.floated(_float_height, _float_time_to_peak, _float_time_to_descent)
		Float_type.LARGE:
			_float_height = 30.0
			_float_time_to_peak = 0.4
#			_float_time_to_descent = 0.5
			_float_time_to_descent = 0.5
			_jump_move_class.floated(_float_height, _float_time_to_peak, _float_time_to_descent)
	
func get_hurt_float_pow():
	return _hurt_float_pow
	
func set_float_pow(value):
	_float_pow = value
	
func get_float_pow():
	return _float_pow

func set_healthUI(flag:bool):
	_healthBarClass.set_visible(flag)
#	if flag:
#		SystemUi.get_enemyHealthUI().setting(self, max_health, health)
#	else:
#		SystemUi.get_enemyHealthUI().disconnect_healthUI()

func set_jump_height(value):
	_jump_height = value
	
func set_jump_time_to_peak(value):
	_jump_time_to_peak = value
	
func set_jump_time_to_descent(value):
	_jump_time_to_descent = value
	
func set_float_height(value):
	_float_height = value
	
func set_float_time_to_peak(value):
	_float_time_to_peak = value
	
func set_float_time_to_descent(value):
	_float_time_to_descent = value
	
func _set_effect(value:String):
	target_effect = value

func deathProcess():
	_healthBarClass.enemy_deathProcess()

func _ready():
	self._health = _max_health
	_healthBarClass = load(_enemy_healthUI).instance()
	SystemUi.add_child(_healthBarClass)
	_healthBarClass.setting(self, _max_health, _health)
	

	
