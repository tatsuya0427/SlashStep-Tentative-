extends Node

class_name AttackPattern

var normalAttackState : StateTemp = null
var duelAttackState : StateTemp = null
var is_duel : bool = false
var effect_pattern : String = ""

func _init(normalAttack:StateTemp, duelAttack:StateTemp, can_duel:bool, target_effect:String):
	normalAttackState = normalAttack
	duelAttackState = duelAttack
	is_duel = can_duel
	effect_pattern = target_effect

func get_normalAttack():
	return normalAttackState
	
func get_duelAttack():
	return duelAttackState

func _get_effect():
	return effect_pattern
