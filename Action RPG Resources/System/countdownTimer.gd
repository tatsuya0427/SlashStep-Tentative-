extends Label

onready var UIList = [$ten, $one]
onready var timer = $Timer
onready var finish = $finish
onready var lowLight = $lowLight
onready var finish_process = $finish_process

onready var finishSE = $finishSE

var process = null

var ms = 0
var s = 0
#制限時間になった際に1度だけシグナルを送信するための変数
var signal_limit = true

var time_limit = 10

func _ready():
	finish.visible = false
	lowLight.visible = false

func timer_start(limit:int, process_class):
	ms = 0
	s = 0
	timer.autostart = true
	signal_limit = false
	time_limit = limit
	process = process_class
	
func _process(delta):
	if !signal_limit:
		if s == time_limit:
			timer.autostart = false
			signal_limit = true
			print("limit!!!")
			finish.visible = true
			lowLight.visible = true
			finishSE.play()
			finish_process.start(1)

		else:
			if ms > 9:
				s += 1
				ms = 0
			
		set_Timer_UI(time_limit - s)
	

func set_Timer_UI(value):
	var rank = 10
	for target_UI in UIList:
		target_UI.change_index(value / rank)
		if(value >= rank):
			value = value % rank
		rank /= 10


func _on_Timer_timeout():
	ms += 1
	pass # Replace with function body.


func _on_finish_process_timeout():
	finish.visible = false
	lowLight.visible = false
	print(process)
	if process != null:
		process.time_out()
