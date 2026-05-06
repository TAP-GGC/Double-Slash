extends Node2D

@export var enemies_on_stage = 4
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var camera = $Camera2D
	camera.make_current()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
