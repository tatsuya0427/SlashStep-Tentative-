extends Sprite

# 衝撃波が有効かどうか
var shockwave_enabled := false

# 衝撃波の中心座標
var shockwave_center := Vector2()

# 衝撃波の半径
var shockwave_radius := 0.12

# 衝撃波の太さ
var shockwave_thickness := 0.01

# 衝撃波の強さ
var shockwave_force := 0.02

func start_shockwave(pos:Vector2):
	# 衝撃波演出開始
	shockwave_enabled = true
	shockwave_radius = 0.12
	shockwave_thickness = 0.01
	shockwave_force = 0.02

	# テクスチャサイズで割合を求める
	var tex_size := texture.get_size()
	shockwave_center.x = pos.x / tex_size.x
	shockwave_center.y = pos.y / tex_size.y

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_pressed():
			# クリックで衝撃波演出開始
			start_shockwave(get_viewport().get_mouse_position())

func _process(delta: float) -> void:
	if shockwave_enabled:
		# 半径サイズを更新
		shockwave_radius += delta
		shockwave_force *= 0.0001 # 徐々に弱くする

		# 各種シェーダーパラメータを設定
		material.set_shader_param("center",    shockwave_center)
		material.set_shader_param("force",     shockwave_force)
		material.set_shader_param("size",      shockwave_radius)
		material.set_shader_param("thickness", shockwave_thickness)

		if shockwave_force < 0.001:
			# 衝撃波終了
			material.set_shader_param("force", 0.0)
			shockwave_enabled = false   
