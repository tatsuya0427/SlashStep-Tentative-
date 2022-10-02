extends Node2D

const MARGIN_X = 8
const START_X = 1024+MARGIN_X # 開始座標
const MIN_W = 240 # 最小の幅

# 状態
enum eState {
	IN, # 入場
	WAIT, # 少し待つ
	OUT, # 退場
}

var _state = eState.IN # 状態
var _timer := 0.0 # タイマー

onready var bg = $ColorRect
onready var label = $Label

func _ready() -> void:
	# 開始位置を設定する
	position.x = START_X

func start(msg:String, color=Color.black) -> void:
	# 開始処理
	label.text = str(msg)
	bg.modulate = color

func _process(delta: float) -> void:
	_timer += delta
	
	# メッセージの横幅を求める
	var font = label.get_theme_default_font()
	var w = font.get_string_size(label.text).x
	# 最低保障の幅より大きければ拡張する
	w = max(w, MIN_W)
	w += MARGIN_X
	
	match _state:
		eState.IN: # 入場中
			position.x = START_X - w * _expo_out(_timer)
			if _timer > 1.0:
				# 少し待つ
				_state = eState.WAIT
				_timer = 0
		eState.WAIT: # 少し待つ
			position.x = START_X - w
			if _timer > 3.0:
				# 退場する
				_state = eState.OUT
				_timer = 0
		eState.OUT: # 退場する
			position.x = START_X - w * (1.0 - _expo_out(_timer))
			if _timer > 1.0:
				# 終了
				queue_free()

func _expo_out(t):
	return -pow(2, -10*t) + 1
