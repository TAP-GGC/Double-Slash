extends Node2D


signal textbox_closed

@export var enemies_on_stage = 1
@onready var player = $Player

func _ready():

	$TutorialTest.hide()

	setup_enemies()
	enemy_removal_handler()
	


func setup_enemies():
	enemies_on_stage = 0
	
	for enemy in get_tree().get_nodes_in_group("Enemies"):
		enemy.is_defeated.connect(on_enemy_died)
		enemies_on_stage += 1


func _process(delta):
	pass


func _on_rial_chan_body_entered(body):
	$TutorialTest.show()
	tutorial()

func _on_rial_chan_body_exited(body: Node2D) -> void:
	$TutorialTest.hide()


func tutorial():
	dialog_use("Welcome to Double Slash//!")
	await textbox_closed
	dialog_use("You may use your hands on the camera 
	or the keyboard and mouse if you get too tired")
	await textbox_closed



func dialog_use(text):
	$TutorialText.show()
	var textBox = $TutorialText/Label
	textBox.text = text

func end_dialog():
	$TutorialTest.hide()
	pass

func _input(event):
	if (Input.is_action_just_pressed("ui_accept") or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)) and $TutorialText.visible:
		$TutorialText.hide()
		emit_signal("textbox_closed")



func enemy_removal_handler():
			if enemies_on_stage == 0:
				$Portal.show()
			else:
				$Portal.hide()

func on_enemy_died():
	enemies_on_stage -= 1
	enemy_removal_handler()
	
	
func dev_button():
	if(Input.is_key_pressed(KEY_M)):
		get_tree().change_scene_to_file($Portal.stage)
