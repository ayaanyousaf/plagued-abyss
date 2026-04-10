extends Area2D

const SPEED = 600.0
var direction = Vector2.ZERO

func _process(delta) -> void:
	position += direction * SPEED * delta
	rotation = direction.angle()
