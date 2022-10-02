extends Sprite

#アニメーション再生状態ならtrue
var now_play_animation = false

func _ready():
	visible = false
	pass
	
func set_Animation():
	visible = true
	now_play_animation = true
	$Tween.interpolate_property(self, "modulate:a", 0.5, 0.0, 1, 3, 1)
	$Tween.start()

#再生するworningアニメーションの設定
func set_Animation_Details(_color:Color, _firstAlpha:float, time):
	visible = true
	now_play_animation = true
	set_modulate(_color)
	$Tween.interpolate_property(self, "modulate:a", _firstAlpha, 0.0, time, 3, 1)
	$Tween.start()
	
func view_Effect(target_frame):
	if(now_play_animation):
		frame = target_frame
	pass
	
func _on_Tween_tween_completed(object, key):
	visible = false
	now_play_animation = false
	pass
