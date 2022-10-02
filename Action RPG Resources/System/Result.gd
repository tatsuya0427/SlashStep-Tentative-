extends Node2D

export(String, FILE, "*.tscn") var titleScene

func _process(delta):
	if Input.is_action_just_pressed("attack"):
		next_page()
	pass

func _on_Button_pressed():
	next_page()
	pass # Replace with function body.

func next_page():
	get_tree().change_scene(titleScene)
