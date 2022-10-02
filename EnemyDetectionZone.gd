extends Area2D

var Enemy = null

func can_see_enemy():
	return Enemy != null

func _on_EnemyDetectionZone_body_entered(body):
	Enemy = body
	
func _on_EnemyDetectionZone_body_exited(body):
	Enemy = null
