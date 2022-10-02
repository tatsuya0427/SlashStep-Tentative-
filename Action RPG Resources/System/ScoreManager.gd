extends Label

onready var UIList = [$million, $thousand, $hundred, $ten, $one]

func _ready():
	GameStats.connect("change_Score_UI", self, "set_Score_UI")
	set_Score_UI(GameStats.gameScore)
	

func set_Score_UI(value):
	var rank = 10000
	for target_UI in UIList:
		target_UI.change_index(value / rank)
		if(value >= rank):
			value = value % rank
		rank /= 10
