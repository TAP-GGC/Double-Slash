extends Node2D

var udp := UDPServer.new()
var port = 5005        # MUST match your Python file

@onready var player = $Player

func _ready():
	udp.listen(port)
	print("Godot listening on UDP port ", port)

func _process(delta):
	udp.poll()

	if udp.is_connection_available():
		var peer = udp.take_connection()
		var packet = peer.get_packet()
		var message = packet.get_string_from_utf8()

		print("Received:", message)

		match message:
			"MOVE_RIGHT":
				player.move_right(delta)

			"MOVE_LEFT":
				player.move_left(delta)

			"MOVE_UP":
				player.move_up(delta)

			"MOVE_DOWN":
				player.move_down(delta)

			"ANSWER_A":
				print("Menu choice A")

			"ANSWER_B":
				print("Menu choice B")

			"ANSWER_C":
				print("Menu choice C")
