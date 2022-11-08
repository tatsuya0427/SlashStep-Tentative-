extends AnimatedSprite

func _ready():
	connect("animation_finished", self, "_on_AnimatedSprite_animation_finished")
	play("Animate")

func _on_AnimatedSprite_animation_finished():
	print("effect queue free")
	queue_free()

#func _on_HitEffect_animation_finished():
#	queue_free()
#	pass # Replace with function body.
