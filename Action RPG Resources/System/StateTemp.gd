extends Node

class_name StateTemp

const NoticeBoard = preload("res://Action RPG Resources/asset/NoticeBoard.tscn")

func _ready():
	print("do extends StateTemp!")

func _enter(m_Owner):
	print("Error: uninherited function [Enter].")
#	_create_ErrorMessage(0)
	pass
	
func _execute(m_Owner):
	print("Error : uninherited function [Execute].")
#	_create_ErrorMessage(1)
	pass
	
func _exit(m_Owner):
	print("Error : uninherited function [Exit].")
#	_create_ErrorMessage(2)
	pass

#-------------------継承を行わなかったときのエラー表示コード------------------------------
var count = 0

# エラーメッセージ
var msg_tbl = [
		"Error uninherited function Enter.",
		"Error uninherited function Execute.",
		"Error uninherited function Exit."
	]
	
# エラーメッセージごとに表示する色を変更
var color_tbl = [
	#enter
	Color.green,
	#execute
	Color.blue,
	#exit
	Color.red
]
		
func _create_ErrorMessage(selectMessage : int):
	var msg = msg_tbl[selectMessage]
	var color = color_tbl[selectMessage]
	print(msg)
	_add_notice(msg, color)
	pass

# 通知ボードを生成する
func _add_notice(msg:String, color:Color = Color.black):
	var notice = NoticeBoard.instance()
	add_child(notice)
	print(msg)
	notice.start(msg, color)
	# 生成数に応じてY座標を移動する
	notice.position.y = 24 * count

	# 生成数をカウントアップする
	count = (count + 1)%20
