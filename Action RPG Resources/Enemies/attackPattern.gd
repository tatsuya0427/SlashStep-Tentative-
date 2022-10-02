extends Node

class_name AttackPattern

var normalAttackState : StateTemp = null
var duelAttackState : StateTemp = null
var is_duel = false

func _init(normalAttack:StateTemp, duelAttack:StateTemp, can_duel:bool):
	normalAttackState = normalAttack
	duelAttackState = duelAttack
	is_duel = can_duel

func get_normalAttack():
	return normalAttackState
	
func get_duelAttack():
	return duelAttackState
