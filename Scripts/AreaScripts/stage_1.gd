extends Node2D
var player_start_x = 8
var player_start_y = 19
@export var enemies_on_stage = 4


func _ready() :
	var camera = $Camera2D
	camera.make_current()
	$Portal.hide()
	setup_enemies()
	enemy_removal_handler()

func setup_enemies():
	enemies_on_stage = 0
	
	for enemy in get_tree().get_nodes_in_group("Enemies"):
		enemy.is_defeated.connect(on_enemy_died)
		enemies_on_stage += 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if enemies_on_stage == 0:
		$Portal.show()
	else:
		$Portal.hide()

func enemy_removal_handler():
			if enemies_on_stage == 0:
				$Portal.show()
			else:
				$Portal.hide()

func on_enemy_died():
	enemies_on_stage -= 1
	enemy_removal_handler()
