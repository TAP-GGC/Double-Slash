extends CharacterBody2D
@onready var player_animations = $playerAnimations
@export var speed: float = 200.0


@warning_ignore("unused_parameter")

func keyboard_detection():
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_A) or  Input.is_key_pressed(KEY_D):
		Movement.ai_movement = false




func _physics_process(delta):
	var input_vector = Vector2.ZERO
	
	
	if Movement.ai_movement:
		input_vector = NetworkManger.ai_direction
	else:
		input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
		input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	
	
	input_vector = input_vector.normalized()
	velocity = input_vector * speed
	keyboard_detection()
	move_and_slide()
	
	if input_vector.x  > 0 || Input.is_action_pressed("ui_right") :
		player_animations.play("walking_right")
	elif input_vector.x  < 0 || Input.is_action_pressed("ui_left"):
		player_animations.play("walking_left")
	elif input_vector.y  > 0 || Input.is_action_just_pressed("ui_down"):
		player_animations.play("walking_down")
	elif input_vector.y  < 0 || Input.is_action_pressed("ui_up"):
		player_animations.play("walking_up")
	else:
		player_animations.play("idle")
		
		
		

   
