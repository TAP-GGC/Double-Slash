extends Control

@onready var camera = $Camera2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	camera.make_current()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_retry_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/EnviromentScenes/mainGame.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()
