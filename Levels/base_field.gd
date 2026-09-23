extends Node2D

@export var spawn_positon: Vector2 = Vector2.ZERO
@export var bonus_points: int = 40

func _process(delta: float) -> void:
	Globals.field_time_left = $BadTimer.time_left
