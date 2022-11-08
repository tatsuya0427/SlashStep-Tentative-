extends AnimatedSprite

onready var enemy_death_se = $enemy_death

func _play_effect(target:String):
	
	match target:
		"AttackEffect":
			pass
		"EnemyDeathEffect":
			enemy_death_se.play()
			pass
	
	connect("animation_finished", self, "_on_AnimatedSprite_animation_finished")
	play(target)

func _on_AnimatedSprite_animation_finished():
	print("effect queue free")
	queue_free()
