extends Node

func hit_flash(sprite: CanvasItem, duration: float = 0.3, shake: float = 1.0) -> void:
	if not is_instance_valid(sprite):
		return

	# stop any flash already running, and undo its leftover shake offset
	if sprite.has_meta("fx_tween"):
		var old: Tween = sprite.get_meta("fx_tween")
		if old and old.is_valid():
			old.kill()
	var leftover: Vector2 = sprite.get_meta("fx_offset", Vector2.ZERO)
	sprite.position -= leftover
	sprite.set_meta("fx_offset", Vector2.ZERO)

	var t := sprite.create_tween()
	sprite.set_meta("fx_tween", t)
	sprite.modulate = Color(1.0, 0.2, 0.2)
	t.set_parallel(true)
	t.tween_method(func(p: float):
		if not is_instance_valid(sprite):
			return
		var new_off := Vector2(randf_range(-1, 1), randf_range(-1, 1)) * shake * (1.0 - p)
		var last_off: Vector2 = sprite.get_meta("fx_offset", Vector2.ZERO)
		sprite.position += new_off - last_off   # only the change, so movement is untouched
		sprite.set_meta("fx_offset", new_off),
		0.0, 1.0, duration)
	t.tween_property(sprite, "modulate", Color.WHITE, duration)
	t.chain().tween_callback(func():
		if not is_instance_valid(sprite):
			return
		sprite.position -= sprite.get_meta("fx_offset", Vector2.ZERO)
		sprite.set_meta("fx_offset", Vector2.ZERO))
