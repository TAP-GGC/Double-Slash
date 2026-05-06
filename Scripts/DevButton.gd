extends Node

@onready var scene = get_tree().current_scene
@onready var portal = scene.find_child("Portal")


func _process(delta: float) -> void:
	dev_button()

func dev_button():
	if(Input.is_key_pressed(KEY_M)):
		print(scene)
		get_tree().change_scene_to_file(portal.stage)   
		
	if(Input.is_key_pressed(KEY_Y)):
		print(get_tree().current_scene)
