extends Label

onready var UIList = [$one]
onready var timer = $Timer
onready var can_move_time = $can_move_timer
onready var start = $start
onready var one = $one
onready var lowLight = $lowLight

onready var countSE = $countSE
onready var startSE = $startSE

#引数に、呼び出し元のClassを格納しておく。
var return_process = null

var ms = 0
var s = 0
#制限時間になった際に1度だけシグナルを送信するための変数
var signal_limit = true

var time_limit = 4

#func _ready():
#	timer_start(15)

#func _ready():
#	timer_start("hoge")

func timer_start(process_class):
	ms = 0
	s = 0
	timer.autostart = true
	signal_limit = false
	start.visible = false
	one.visible = true
	lowLight.visible = true
	return_process = process_class
	
func _process(delta):
	if !signal_limit:
		if s == time_limit:
			timer.autostart = false
			signal_limit = true
			print("limit!!!")
			start.visible = true
			one.visible = false
			startSE.play()
			can_move_time.start(1)
		else:
			if ms > 9:
				s += 1
				ms = 0
				print(s)
				countSE.play()
		set_Timer_UI(time_limit - s)
	

func set_Timer_UI(value):
	var rank = 1
	for target_UI in UIList:
		target_UI.change_index(value / rank)
		if(value >= rank):
			value = value % rank
		rank /= 10


func _on_Timer_timeout():
	ms += 1
	pass # Replace with function body.


func _on_can_move_timer_timeout():
	if return_process != null:
		start.visible = false
		lowLight.visible = false
		return_process.settingGameManager()
