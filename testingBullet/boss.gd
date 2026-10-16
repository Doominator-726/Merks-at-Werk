class_name Boss
extends "res://Enemy/enemy.gd"

signal died

var max_health : int = 100

func hit(damage = 1) -> void:
	HitAnim.hit_flash(self, 0.2, 0.0) 
	health -= damage
	if health <= 0:
		died.emit()   # doesn't call explode(), so the boss isn't freed

func set_active(on: bool) -> void:
	for c in get_children():
		if c is CollisionShape2D:
			c.set_deferred("disabled", not on)
func _draw() -> void:
	draw_circle(Vector2.ZERO, 24, Color.CRIMSON)
