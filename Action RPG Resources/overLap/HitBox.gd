extends Area2D

export var damage = 1 setget change_Damage
export var knockback_pow = 0 setget change_Knockback_Pow

var knockback_vector = Vector2.ZERO
onready var collision = $CollisionShape2D

func change_Damage(value):
	damage = value
	pass
	
func change_Knockback_Pow(value):
	knockback_pow = value
	pass
