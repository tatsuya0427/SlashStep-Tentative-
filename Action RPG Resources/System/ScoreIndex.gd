extends AnimatedSprite

onready var numImage = self

func change_index(num):
	numImage.frame = num
