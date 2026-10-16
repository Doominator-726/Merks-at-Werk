class_name Boss
extends "res://Enemy/enemy.gd"

signal died

var max_health : int = 100

@export var display_name : String = "Boss":
	set(v):
		display_name = v
		queue_redraw()


func hit(damage = 1) -> void:
	HitAnim.hit_flash(self, 0.2, 0.0)
	health -= damage
	if health <= 0:
		died.emit()


func set_active(on: bool) -> void:
	for c in get_children():
		if c is CollisionShape2D:
			c.set_deferred("disabled", not on)


func _draw() -> void:
	draw_circle(Vector2.ZERO, 24, Color.CRIMSON)
	draw_string(ThemeDB.fallback_font, Vector2(-80, -36), display_name,
		HORIZONTAL_ALIGNMENT_CENTER, 160, 16, Color.WHITE)
