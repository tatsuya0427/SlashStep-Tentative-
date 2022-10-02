extends Node

const NoticeBoard = preload("res://Action RPG Resources/asset/NoticeBoard.tscn")

var count = 0

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		print("show!")
		# ランダムで表示するメッセージ
		var msg_tbl = [
			"デバッグメッセージ",
			"警告メッセージ",
			"エラーメッセージ",
		]
		
		# ランダムで変化する色
		var color_tbl = [
			Color.black,
			Color.yellow,
			Color.red
		]
		
		#var msg = _choice(msg_tbl)
		#var color = _choice(color_tbl)
		var rnd = randi()%3
		var msg = msg_tbl[rnd]
		msg += str(count)
		var color = color_tbl[rnd]
		
		# 通知ボードを表示する
		_add_notice(msg, color)

# リストから抽選を行う
func _choice(tbl):
	var length = tbl.size()
	var rnd = randi()%length
	return tbl[rnd]

# 通知ボードを生成する
func _add_notice(msg:String, color:Color = Color.black):
	var notice = NoticeBoard.instance()
	add_child(notice)
	notice.start(msg, color)
	# 生成数に応じてY座標を移動する
	notice.position.y = 24 * count

	# 生成数をカウントアップする
	count = (count + 1)%20
