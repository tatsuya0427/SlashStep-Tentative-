extends Node2D

var collision_pos = []

#----初期化する際に使用するPlayerState--
#var stats = PlayerStats
#-----------------------------------

#-------カメラ制御のためのtileMapの大きさを保存-------
#var stepMap = get_node("Grass").get_used_rect()
var map_limits
var map_cell_size
#-----------------------------------

func _ready():
	worldScene_Initialization()
	
#	print(stepMap)
#	print(stepMap.get_used_rect())
#	map_limits = stepMap.get_used_rect()
#	map_cell_size = stepMap.cell_size

func get_map_rect():
	return get_node("stepHightTile").get_used_rect()
	
func get_map_cellSize():
	return get_node("stepHightTile").cell_size

#worldSceneの初期化
func worldScene_Initialization():
	#playerのHP初期化
#	stats.health = stats.max_health
	
	#Scoreの初期化
	GameStats.reset_Score()
	GameStats.gameScore = 0
	
	print("reset!")
	for node in get_children():
		if node.name.find("GameManager") != -1:
#			node.settingGameManager()
			node.start_countDown()
	pass

func _on_Character_collided(collision):
	if collision.collider is TileMap:
		var tile_pos = collision.collider.world_to_map($Player.position)
		tile_pos -= collision.normal
		var tile = collision.collider.get_celly(tile_pos)
		print(tile.name)
