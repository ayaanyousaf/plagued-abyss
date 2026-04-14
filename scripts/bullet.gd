extends Area2D

const SPEED = 600.0
var direction = Vector2.ZERO
var damage = 1

func _process(delta) -> void:
	position += direction * SPEED * delta
	rotation = direction.angle()

func _on_body_entered(body: Node2D) -> void:
	if (body.is_in_group("enemy")): 
		body.take_damage(damage)
		queue_free()
