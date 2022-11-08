extends Node2D

class_name PlayerStats

enum Float_type{
	NONE,
	SMALL,
	MEDIUM,
	LARGE
}

#enum CharaType{
#	PLAYER,
#	ENEMY,
#	OBJECT
#}
#export(String, FILE, ".*tscn") var player_healthUI
var _player_data = null

onready var _player_healthUI = load("res://Action RPG Resources/UI/PlayerHealthUI.tscn")
export(int) var _max_health = 15 setget set_max_health, get_max_health
var _health = _max_health setget set_health, get_health

onready var _player_exhUI = load("res://Action RPG Resources/UI/PlayerEXGageUI.tscn")
export(int) var _max_ex_point = 1 setget set_max_ex, get_max_ex
var _ex_point = 0 setget set_ex, get_ex

export (int) var _power = 1 setget set_power, get_power
var knockback_vector = Vector2.ZERO
var knockback_pow = 0
#----------ジャンプまたは吹っ飛び関係-------------
export (Float_type) var _hurt_float_pow = Float_type.NONE setget set_hurt_float_pow, get_hurt_float_pow
export (Float_type) var _float_pow = Float_type.NONE setget set_float_pow, get_float_pow
#---------------------------------------------
#-----------攻撃時に再生するeffect---------
var target_effect : String = "" setget _set_effect
#----------------------------------------

onready var _jump_move_class = $"../jump_move"

#生成したhealthBarClassを格納しておく変数
var _healthBarClass

var _exBarClass
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
	_max_health = value
	self._health = min(_health, _max_health)
	emit_signal("max_health_changed", _max_health)

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
		
func set_max_ex(value):
	_max_ex_point = value
	self._ex_point = min(_ex_point, _max_ex_point)
	emit_signal("max_ex_changed", _max_ex_point)

func get_max_ex():
	return _max_ex_point

func set_ex(value):
	_ex_point = value
#	print("ex " + str(_ex_point))
#	print("set stats health" + str(health))
	emit_signal("ex_changed", _ex_point)

func get_ex():
	return _ex_point

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
			_jump_move_class._jump_height = 5.0
			_jump_move_class._jump_time_to_peak = 0.1
			_jump_move_class._jump_time_to_descent = 1.0
		Float_type.MEDIUM:
			_jump_move_class._jump_height = 20.0
			_jump_move_class._jump_time_to_peak = 0.2
			_jump_move_class._jump_time_to_descent = 1.0
		Float_type.LARGE:
			_jump_move_class._jump_height = 30.0
			_jump_move_class._jump_time_to_peak = 0.3
			_jump_move_class._jump_time_to_descent = 1.0

func get_hurt_float_pow():
	return _hurt_float_pow
	
func set_float_pow(value):
	_float_pow = value
	
func get_float_pow():
	return _float_pow
	
func _set_effect(value:String):
	target_effect = value
	
func setting(player):
	print("------------")
	print(get_parent())
	print(str(_max_health))
	print("------------")
	self._health = _max_health
	print(_max_health)
	print(_power)
	
	_player_data = player
	
#	PlayerHealthUi.setting(self, max_health)
#	SystemUi.get_playerHealthUI().setting(self, max_health, health)
#	PlayerHealthUi.max_hearts = max_health
#	PlayerHealthUi.hearts = max_health

#	print("hogehoge")
#	print(_player_healthUI)
#	print("hogehoge")
#	healthBarClass = load(player_healthUI).instance()
	_healthBarClass = _player_healthUI.instance()
	SystemUi.add_child(_healthBarClass)
	_healthBarClass.setting(self, _max_health, _health)
	#SystemUIにhealthberを追加した後変数として代入しておき、SystemUI上の関数で表示非表示できるようにする
	
	_exBarClass = _player_exhUI.instance()
	SystemUi.add_child(_exBarClass)
	_exBarClass.setting(self, _max_ex_point, _ex_point)
	pass

func _ready():
#	print("------------")
#	print(get_parent())
#	print(str(_max_health))
#	print("------------")
#	self._health = _max_health
#	print(_max_health)
#
##	PlayerHealthUi.setting(self, max_health)
##	SystemUi.get_playerHealthUI().setting(self, max_health, health)
##	PlayerHealthUi.max_hearts = max_health
##	PlayerHealthUi.hearts = max_health
#
#	print("hogehoge")
#	print(_player_healthUI)
#	print("hogehoge")
##	healthBarClass = load(player_healthUI).instance()
#	_healthBarClass = _player_healthUI.instance()
#	SystemUi.add_child(_healthBarClass)
#	_healthBarClass.setting(self, _max_health, _health)
#
#	_exBarClass = _player_exhUI.instance()
#	SystemUi.add_child(_exBarClass)
#	_exBarClass.setting(self, _max_ex_point, _ex_point)
#	healthBarClass = SystemUi.get_playerHealthUI()
#	healthBarClass.setting(self, max_health, health)
#	SystemUi.get_playerHealthUI().setting(self, max_health, health)
#	healthUI.setting(max_health)
	pass
