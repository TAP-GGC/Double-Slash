extends Area2D
signal is_defeated
@export var enemy: enemy_data


func _ready():
	add_to_group("Enemies")
	$Sprite2D.texture = enemy.sprite.duplicate()

func _on_body_entered(body):
	start_battle()


func start_battle():
	get_tree().paused = true
	var battle_scene = preload("res://Scenes/BattleScenes/battle.tscn").instantiate()
	battle_scene.setup(enemy.duplicate())
	get_tree().current_scene.add_child(battle_scene)
	battle_scene.connect("enemy_defeated", defeated)
	


func defeated():
	emit_signal("is_defeated")
	queue_free()
