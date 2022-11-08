extends Area2D

export(String, FILE, "*.tscn") var _spawnerScene
onready var _gameManager = get_parent().get_node("GameManager")
onready var _spawnAreaCol = $SpawnerAreaCol

func _on_SpawnerArea_area_entered(area):
	_spawnAreaCol.set_deferred("disabled", true)
	var _spawner = load(_spawnerScene).instance()
	print(get_tree().get_root().get_node("WorldManager").get_node("SpawnerArea").position)
	
	_spawner.position = Vector2.ZERO
#	_gameManager.global_position = self.global_position
#	print(_spawner.get_name())
	add_child(_spawner)
	_gameManager.on_spawnArea(_spawner)

