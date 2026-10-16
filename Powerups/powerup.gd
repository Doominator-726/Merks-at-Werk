class_name Powerup
extends Area2D

## Leave empty to advance the player to the next tier.
@export var shot_pattern: ShotPattern
@export var lifetime: float = 0.0
@export var speed: float = 0.0
var axis: Vector2 = Vector2.ZERO
var _collected: bool = false


func _ready() -> void:
	if lifetime > 0:
		$DespawnTimer.start(lifetime)
	var base_scale: Vector2 = $Sprite2D.scale
	var tween = create_tween().set_loops()
	tween.tween_property($Sprite2D, "scale", base_scale * 1.2, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property($Sprite2D, "scale", base_scale, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func _physics_process(delta: float) -> void:
	if speed != 0:
		position += axis * speed * delta


func _on_body_entered(body: Node2D) -> void:
	if _collected or not body.is_in_group("player"):
		return
	_collected = true
	if shot_pattern:
		body.set_shot_pattern(shot_pattern)
	else:
		body.upgrade_weapon()
	queue_free()


func get_sprite() -> Sprite2D:
	return $Sprite2D


func _on_despawn_timer_timeout() -> void:
	queue_free()
