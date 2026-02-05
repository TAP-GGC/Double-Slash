extends Sprite2D

var speed = 200

func move_right(delta):
	position.x += speed * delta

func move_left(delta):
	position.x -= speed * delta

func move_up(delta):
	position.y -= speed * delta

func move_down(delta):
	position.y += speed * delta
