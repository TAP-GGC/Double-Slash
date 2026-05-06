extends Area2D

@export var to_where = "stage 1"
@onready var portal = $AnimatedSprite2D
var stage
func _ready():
	if to_where == "stage 1":
		$AnimatedSprite2D.play("stage 1")
		stage = "res://Scenes/EnviromentScenes/Stage1.tscn"
	elif to_where == "stage_2":
		$AnimatedSprite2D.play("stage_2") 
		stage = "res://Scenes/EnviromentScenes/stage_2.tscn"
	else:
		$AnimatedSprite2D.play("stage_3")
		stage = "res://Scenes/EnviromentScenes/stage_3.tscn"


func _process(delta: float) -> void:
	if (!visible):
		print("im hidden")
		set_collision_mask_value(5, false)
	else:
		set_collision_mask_value(5, true)
		
	
func _on_body_entered(body) :
	get_tree().change_scene_to_file(stage)
