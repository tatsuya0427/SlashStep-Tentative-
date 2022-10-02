extends Node2D

const GrassEffect = preload("res://Action RPG Resources/Effects/GrassEffect.tscn")

func create_grass_effect():
	var grassEffect = GrassEffect.instance()#Unityのclone
	get_parent().add_child(grassEffect)
	grassEffect.global_position = global_position#GrassのグローバルポジションをEffectのポジションにも反映

func _on_HurtBox_area_entered(area):
	create_grass_effect()
	queue_free()
