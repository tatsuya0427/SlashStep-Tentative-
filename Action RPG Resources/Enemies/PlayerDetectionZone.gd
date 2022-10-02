extends Area2D

var player = null
var is_area_target = false

func can_see_player():
	return player != null

func _on_PlayerDetectionZone_body_entered(body):
	player = body
	is_area_target = true

func _on_PlayerDetectionZone_body_exited(body):
#	player = null
	is_area_target = false
