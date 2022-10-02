extends "res://Action RPG Resources/overLap/HitBox.gd"

func _ready():
	damage = PlayerStats.power
	collision.disabled = true
