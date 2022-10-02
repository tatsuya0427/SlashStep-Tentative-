extends Area2D

func _on_TargetDetectionZone_area_entered(body):
	print(body + " in")
	get_parent().target = body


func _on_TargetDetectionZone_area_exited(body):
	get_parent().target = null
	print("out")
