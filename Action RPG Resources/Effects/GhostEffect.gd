extends Sprite

export(float) var ghost_live_time

# ゴーストエフェクト開始
func start(_position:Vector2, _scale:Vector2, _frame:int, _flip_h:bool, _color:Color, time:float):
	position = _position
	scale = _scale
	frame = _frame
	flip_h = _flip_h
	set_modulate(_color)
	ghost_live_time = time

func _process(delta: float) -> void:
	print("ghost")
	ghost_live_time -= delta
	if ghost_live_time <= 0:
		# タイマー終了で消える
		queue_free()

	var alpha = ghost_live_time * 0.5
	modulate.a = alpha
