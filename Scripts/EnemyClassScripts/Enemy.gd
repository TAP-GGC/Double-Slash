extends Area2D


func _on_body_entered(body):
	start_battle()



func start_battle():
	
	get_tree().paused = true
	var battle_scene = preload("res://Scenes/BattleScenes/battle.tscn").instantiate()
	battle_scene.setup("res://resources/EnemyResources/BaseEnemy.gd")
	get_tree().root.add_child(battle_scene)
	get_tree().current_scene.queue_free()
	

func is_defeated():
	pass
	
