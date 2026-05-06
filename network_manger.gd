extends Node

var udp := UDPServer.new()
var peer : PacketPeerUDP
var port = 5005
var ai_direction = Vector2.ZERO
var ai_active
var ai_target_direction: Vector2 = Vector2.ZERO
var last_message = ""

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS 
	udp.listen(port)
	print("Listening on", port)

func _process(delta: float) -> void:
	udp.poll()
	ai_direction = Vector2.ZERO
	ai_active = true
	# Accept connection ONCE
	if peer == null and udp.is_connection_available():
		peer = udp.take_connection()
		print("AI connected!")

	# If we have a peer, read packets continuously
	if peer and peer.get_available_packet_count() > 0:
		var packet = peer.get_packet()
		var message = packet.get_string_from_utf8()
		
		last_message = message
		print("Received:", message)

		match message:
			"MOVE_RIGHT":
				ai_direction = Vector2.RIGHT
				Movement.ai_movement = true
				ai_active = true
			"MOVE_LEFT":
				ai_direction = Vector2.LEFT
				Movement.ai_movement = true
				ai_active = true
			"MOVE_UP":
				ai_direction = Vector2.UP
				ai_active = true
				Movement.ai_movement = true
			"MOVE_DOWN":
				ai_direction = Vector2.DOWN
				Movement.ai_movement = true
				ai_active = true
			"ANSWER_A":
				print("Menu choice A")

			"ANSWER_B":
				print("Menu choice B")

			"ANSWER_C":
				print("Menu choice C")
				
			"STOP":
				ai_target_direction = Vector2.ZERO
	var smoothing_speed = 5.0  # higher = snappier, lower = smoother
	ai_direction = ai_direction.lerp(ai_target_direction, smoothing_speed * delta)


func release_all_movement():
	Input.action_release("ui_right")
	Input.action_release("ui_left")
	Input.action_release("ui_up")
	Input.action_release("ui_down")
