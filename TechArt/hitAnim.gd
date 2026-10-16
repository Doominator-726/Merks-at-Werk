extends Node

func hit_flash(sprite: CanvasItem, duration: float = 0.3, shake: float = 1.0) -> void:
	if not is_instance_valid(sprite):
		return
	# stop any flash already running so hits don't stack
	if sprite.has_meta("fx_tween"):
		var old: Tween = sprite.get_meta("fx_tween")
		if old and old.is_valid():
			old.kill()
	var base_pos: Vector2 = sprite.get_meta("fx_base_pos", sprite.position)
	sprite.set_meta("fx_base_pos", base_pos)

	var t := sprite.create_tween()
	sprite.set_meta("fx_tween", t)
	sprite.modulate = Color(1.0, 0.2, 0.2)
	t.set_parallel(true)
	t.tween_method(func(p: float):
		sprite.position = base_pos + Vector2(randf_range(-1, 1), randf_range(-1, 1)) * shake * (1.0 - p),
		0.0, 1.0, duration)
	t.tween_property(sprite, "modulate", Color.WHITE, duration)
	t.chain().tween_callback(func(): sprite.position = base_pos)
