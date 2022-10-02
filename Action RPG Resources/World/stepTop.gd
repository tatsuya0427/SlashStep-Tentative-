extends Area2D

#signal intoStepTopArea
var hight = 8

func _ready():
#	self.connect("intoStepTopArea", self, "_change_hitBox_state")
	#connect("inStep", "Player", )
#	connect("inStep", get_node("../../Player"), "_get_on_Step")
#	connect("outStep", get_node("../../Player"), "_get_off_Step")
#	get_node("../../Player").CONNECT_ONESHOT
	pass # Replace with function body.

#func _change_hitBox_state():
#	pass

func _on_stepTop_body_entered(area):
	if area.name == "Player":
		
		area._get_on_Step(self)
	pass # Replace with function body.

func _on_stepTop_body_exited(area):
	if area.name == "Player":
		area._get_off_Step(self)
#	emit_signal("outStep", stepHight)
	#get_node("../../Player").call_deferred("_get_off_step", stepHight)
	#get_node("../../Player")._get_off_step(stepHight)
#	get_node("../../Player").z_floor -= stepHight
	pass # Replace with function body.
	
#	var a = find_node("hoge")
#if a.aaa == "fuga":
