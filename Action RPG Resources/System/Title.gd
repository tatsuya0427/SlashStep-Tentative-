extends Node2D

func _ready():
	SystemUi.visible = false

func _process(delta):
	if Input.is_action_just_pressed("attack"):
		next_page()
	pass

func _on_Button_pressed():
	next_page()

func next_page():
	get_tree().change_scene("res://Action RPG Resources/World/World.tscn")
	GameStats.gameScore = 0
	for node in get_tree().get_root().get_children():
		if node.name.find("WorldManager") != -1:
			node.worldScene_Initialization()
	pass # Replace with function body.

#Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"))
#(Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up"))
#Input.is_action_just_pressed("attack")
