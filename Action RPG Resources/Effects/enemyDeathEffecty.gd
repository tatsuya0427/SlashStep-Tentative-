extends AnimatedSprite

onready var death_SE = $deathSE

func _ready():
	connect("animation_finished", self, "_on_AnimatedSprite_animation_finished")
	death_SE.play()
	play("Animate")

func _on_AnimatedSprite_animation_finished():
	queue_free()
