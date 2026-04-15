extends Node2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	rotation = randf_range(0.0, TAU)
	scale = Vector2.ONE * randf_range(0.9, 1.2)
	sprite.play("default")

func _on_animated_sprite_2d_animation_finished() -> void:
	queue_free()
