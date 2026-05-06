extends Control

signal enemy_defeated
signal textbox_closed
signal attack_button_pressed(button_pressed)
signal ai_pressed


@export var enemyData: enemy_data

@onready var container = $ActionPanelOptions/HBoxContainer
@onready var children = container.get_children()
var current_player_health = 0
var current_enemy_health = 0
var is_defending = false
var bit_font = load("res://Assets/ithaca-font/Ithaca-LVB75.ttf")
var ai_input = InputEventAction.new()
var int_dict ={
	1:"10",
	2:"7",
	3:"3",
	4:"8",
	5:"6"
}
var double_dict={
	1:"2.5",
	2:"7.0",
	3:"22.1",
	4:"12.5",
	5:"14.8"
}
var string_dict={
	1:"\"Hello, World\"",
	2: "\"Cat\"",
	3: "\"Dog\"",
	4: "\"Welcome\"",
	5: "\"Workshop\""
}
var bool_dict={
	1:'true',
	2:'false',
	3:'true',
	4:'false',
	5:'true'
}
var if_dict={
	1: "If (age >= 18)",
	2: "If (gameIsGood == true)",
	3: "If (!true)",
	4: "If (health > 0)",
	5: "If (grade >= 90)"
}
var for_dict={
	1: "for (int i = 0)",
	2: "for (int j = 10)",
	3: "for (int i = s.length())",
	4: "for (int n = 0)",
	5: "for (int j = s.size()-1)"
}







@onready var int_button = $ActionPanelOptions/HBoxContainer/Int
@onready var double_button = $ActionPanelOptions/HBoxContainer/Double
@onready var string_button = $ActionPanelOptions/HBoxContainer/String

#Processes everything that needs to be at the start of the battle scene 
#(Enemy data(sprite, damage, health,etc.), Background, and player health
func setup(enemy: enemy_data):
	$attack_animation.hide()
	enemyData = enemy
	set_health($EnemyContainer/MarginContainer/ProgressBar, enemyData.health, enemyData.health)
	set_health($PlayerPanel/PlayerData/MarginContainer/ProgressBar, State.current_health, State.max_health)
	current_player_health = State.current_health
	current_enemy_health = enemyData.health
	$enemyBattle.sprite_frames = enemy.battle_sprite
	$enemyBattle.play("default")
	
	if enemyData.stage == "stage 2":
		$Background.texture = preload("res://Assets/BackgroundFights/Backgrounds2(Blue).png")
		for button in $ActionPanel/Actions.get_children():
			if button is TextureButton:
				button.texture_normal = load("res://Assets/CharacterAndEnemySprites/Button2.png")
				button.texture_hover = load("res://Assets/CharacterAndEnemySprites/Button2Hover.png")
				button.texture_pressed = load("res://Assets/CharacterAndEnemySprites/Button2Pressed.png")
				
		for button in $ActionPanelOptions.get_children():
			if button is TextureButton:
				button.texture_normal = load("res://Assets/CharacterAndEnemySprites/AttackAction2.png")
				button.texture_hover = load("res://Assets/CharacterAndEnemySprites/AttackAction2Hover.png")
				button.texture_pressed = load("res://Assets/CharacterAndEnemySprites/AttackAction2Pressed.png")
	elif enemyData.stage == "stage 3":
		$Background.texture = preload("res://Assets/BackgroundFights/Background3(Purple).png")
		for button in $ActionPanel/Actions.get_children():
			if button is TextureButton:
				button.texture_normal = load("res://Assets/CharacterAndEnemySprites/Button2.png")
				button.texture_hover = load("res://Assets/CharacterAndEnemySprites/Button2Hover.png")
				button.texture_pressed = load("res://Assets/CharacterAndEnemySprites/Button2Pressed.png")
	else:
		pass
func _process(delta):
	dev_button()
	ai_control()
	ai_control_options()


func battle_ended():
	get_tree().paused = false
	queue_free()

func _ready():
	if enemyData.name == "VByte":
		print("boss battle")
		$bossbattleMusic.play()
	else:
		$battleMusic.play()
	enemy_title()
	var camera = $Camera2D
	camera.make_current()
	
	enemy_type_button()
	$EnemyContainer/MarginContainer/ProgressBar/enemyTypeLabel.text = enemyData.type
	$TextBox.hide()
	$ActionPanel.hide()
	$ActionPanelOptions.hide()
	
	display_text("A wild %s appeared!!" % enemyData.name)
	await textbox_closed
	$ActionPanel.show()
	
#Handles textbox closing
func _input(event):
	if (Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) or Input.is_action_pressed("ui_accept")) and $TextBox.visible:
		$TextBox.hide()
		emit_signal("textbox_closed")


func set_health(progress_bar, health, max_Health):
	progress_bar.value = health
	progress_bar.max_value = max_Health
	progress_bar.get_node("Label").text = "Hp: %d/%d" % [health, max_Health]
	
func display_text(text):
	$TextBox.show()
	$TextBox/Label.text = text
	$TextBox/Label.add_theme_font_override("font", bit_font)

func enemy_turn() :
	assign_enemy_type()
	$ActionPanel.hide()
	display_text("%s hits you with its cords" % enemyData.name)
	await textbox_closed
	if is_defending:
		is_defending = false
		display_text("You defended sucessfully")
		await textbox_closed
	else:
		current_player_health = max(0, current_player_health - enemyData.damage)
		set_health($PlayerPanel/PlayerData/MarginContainer/ProgressBar, current_player_health, State.max_health)
	lost()
	$ActionPanel.show()



func _on_run_pressed() :
	$ActionPanel.hide()
	display_text("You got away safely")
	await(get_tree().create_timer(1).timeout)
	battle_ended()
func _on_attack_pressed() :
	$ActionPanel.hide()
	label_type()
	enemy_type_button()
	button_swap()
	$ActionPanelOptions.show()
	
	var type = await attack_button_pressed
	$ActionPanelOptions.hide()
	print(type, enemyData.type)
	if type == enemyData.type:
		attack_landed()
	else:
		display_text("Wrong Type")
		await(get_tree().create_timer(2).timeout)
		enemy_turn()
func _on_defend_pressed():
	$ActionPanel.hide()
	is_defending = true
	display_text("You prepare for an attack")
	enemy_turn()
func attack_landed():
	display_text("You swing your sword!")
	await textbox_closed
	
	current_enemy_health = max(0, current_enemy_health - State.damage)
	set_health($EnemyContainer/MarginContainer/ProgressBar, current_enemy_health, enemyData.health)
	$attack_animation.show()
	$attack_animation.play("Attack")
	$battlePlayer.play("Attack")
	await $attack_animation.animation_finished
	$attack_animation.hide()
	$AnimationPlayer.play("enemy_damage")
	
	if (current_enemy_health == 0 and enemyData.name == "VByte"):
		display_text("%s was defeated!" % enemyData.name)
		await textbox_closed
		emit_signal("enemy_defeated")
		get_tree().change_scene_to_file("res://Scenes/EnviromentScenes/mainGame.tscn")
	elif current_enemy_health == 0:
		display_text("%s was defeated!" % enemyData.name)
		await textbox_closed
		emit_signal("enemy_defeated")
		battle_ended()
		
	await $AnimationPlayer.animation_finished
	enemy_turn()



#Handles event for the option buttons "int, double, string" in their respective places
func _on_int_pressed() -> void:
	print("Im being pressed")
	print(enemyData.type)
	if enemyData.type == "Int" or  enemyData.type == "Double" or  enemyData.type == "String":
		print("This is the button")
		emit_signal("attack_button_pressed", "Int")
	elif enemyData.type == "Boolean" or  enemyData.type == "If-Statement" or  enemyData.type == "Loop":
		emit_signal("attack_button_pressed", "Boolean")
func _on_double_pressed() -> void:
	if enemyData.type == "Int" or  enemyData.type == "Double" or  enemyData.type == "String":
		print("This is the button")
		emit_signal("attack_button_pressed", "Double")
	elif enemyData.type == "Boolean" or  enemyData.type == "If-Statement" or  enemyData.type == "Loop":
		emit_signal("attack_button_pressed", "If-Statement")
func _on_string_pressed() -> void:
	if enemyData.type == "Int" or  enemyData.type == "Double" or  enemyData.type == "String":
		emit_signal("attack_button_pressed", "String")
	elif enemyData.type == "Boolean" or  enemyData.type == "If-Statement" or  enemyData.type == "Loop":
		emit_signal("attack_button_pressed", "Loop")


func assign_enemy_type():
	var type_dictionary = {
		1: "Int",
		2: "Double",
		3: "String",
		4: "Boolean",
		5: "If-Statement",
		6: "Loop"
	}
	
	
	if enemyData.name == "VByte":
		var typeNumb = randi() % 6 + 1
		
		enemyData.type = type_dictionary[typeNumb]
		$EnemyContainer/MarginContainer/ProgressBar/enemyTypeLabel.text = enemyData.type


func ai_control():
	if !$ActionPanel.visible and !$TextBox.visible:
		return
	
	if NetworkManger.last_message == "":
		return

	match NetworkManger.last_message:

		"ANSWER_A":
			_on_attack_pressed()

		"ANSWER_B":
			_on_run_pressed()

		"ANSWER_C":
			pass

		"ANSWER_D":
			ai_input.action = "ui_accept"
			ai_input.pressed = true
			Input.parse_input_event(ai_input)

	NetworkManger.last_message = ""
func ai_control_options():
	if !$ActionPanelOptions.visible:
		return
	
	if NetworkManger.last_message == "":
		return

	match NetworkManger.last_message:

		"ANSWER_A":
			children[0].emit_signal("pressed")

		"ANSWER_B":
			children[1].emit_signal("pressed")

		"ANSWER_C":
			children[2].emit_signal("pressed")
			
		"ANSWER_D":
			ai_input.pressed = true
			Input.parse_input_event(ai_input)
			

	NetworkManger.last_message = ""



func label_type():
	print("Working")
	for label in $ActionPanelOptions.get_children():
		if label is Label:
			print("I am a label")


func enemy_type_button():
	var random = randi() % 5 + 1
	if enemyData.type == "Boolean" or  enemyData.type == "If-Statement" or  enemyData.type == "Loop":
		$ActionPanelOptions/HBoxContainer/Int/Label.text = bool_dict[random]
		$ActionPanelOptions/HBoxContainer/Double/Label.text = if_dict[random]
		$ActionPanelOptions/HBoxContainer/String/Label.text = for_dict[random]
	else:
		$ActionPanelOptions/HBoxContainer/Int/Label.text = int_dict[random]
		$ActionPanelOptions/HBoxContainer/Double/Label.text = double_dict[random]
		$ActionPanelOptions/HBoxContainer/String/Label.text = string_dict[random]


func lost():
	if current_player_health == 0:
		display_text("You died! Try again")
		await(get_tree().create_timer(2).timeout)
		battle_ended()

func enemy_title():
	$Label.text = enemyData.name
	

func button_swap():
	
	children.shuffle()
	
	for i in range(children.size()):
		container.move_child(children[i], i)


func dev_button():
	if(Input.is_key_pressed(KEY_V)):
		print($ActionPanelOptions/HBoxContainer.get_children())
		
	if(Input.is_key_pressed(KEY_U)):
		emit_signal("enemy_defeated")
		battle_ended()
