extends Node2D

@export var radius : float = 6.0
var hitbox_dot : Node2D


func _draw() -> void:
	draw_circle(Vector2.ZERO, radius + 1.5, Color.WHITE)
	draw_circle(Vector2.ZERO, radius, Color.RED)
