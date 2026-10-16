class_name BulletHellArena
extends Node2D

signal finished(won: bool)

@export var dot_radius : float = 4
@export var hitbox_offset : Vector2 = Vector2(-6, 0)
@export var player : Node2D
@export var arena_rect : Rect2 = Rect2(-320, -240, 640, 480)
@export var boss_y_offset : float = 100.0
@export var boss_move_speed : float = 120.0
@export var bullet_radius : float = 5.0
@export var max_bullets : int = 5000
@export var freeze_time : float = 1.0
@export var lerp_time : float = 0.8
@export var player_margin : float = 8.0

@onready var boss : Boss = $Boss

var patterns : Array = []
var phase : int = 0
var phase_time : float = 0.0
var bullet_pos : PackedVector2Array = PackedVector2Array()
var bullet_vel : PackedVector2Array = PackedVector2Array()
var bullet_mm : MultiMeshInstance2D
var active : bool = false
var shot_timer : float = 0.0
var spiral_angle : float = 0.0
var invuln : float = 0.0
var move_timer : float = 0.0
var target_x : float = 0.0
var warning_alpha : float = 0.0
var hitbox_dot : Node2D


func _ready() -> void:
	visible = false
	process_physics_priority = 100
	boss.died.connect(_next_pattern)
	boss.set_active(false)
	_setup_bullet_renderer()

	patterns = [
		{
			"health": 40, "time": 30.0, "fn": _pattern_ring,
			"count": 50, "speed": 50.0, "interval": 0.1,
		},
		{
			"health": 60, "time": 35.0, "fn": _pattern_spiral,
			"arms": 2, "speed": 170.0, "interval": 0.07, "turn": 0.35,
		},
		{
			"health": 80, "time": 40.0, "fn": _pattern_aimed,
			"shots": 5, "spread": 0.22, "speed": 220.0, "interval": 0.8,
			"ring_count": 16, "ring_speed": 90.0,
		},
	]

	start.call_deferred()


func _setup_bullet_renderer() -> void:
	var size := int(ceil(bullet_radius * 2.0))
	var img := Image.create(size, size, false, Image.FORMAT_RGBA8)
	var c := Vector2(size, size) / 2.0
	var inner := bullet_radius - 2.0

	for y in size:
		for x in size:
			var d := Vector2(x + 0.5, y + 0.5).distance_to(c)
			var core := clampf(inner - d + 0.5, 0.0, 1.0)
			var col := Color.WHITE.lerp(Color.HOT_PINK, core)
			col.a = clampf(bullet_radius - d + 0.5, 0.0, 1.0)
			img.set_pixel(x, y, col)

	var quad := QuadMesh.new()
	quad.size = Vector2(size, size)

	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_2D
	mm.mesh = quad
	mm.instance_count = max_bullets
	mm.visible_instance_count = 0

	bullet_mm = MultiMeshInstance2D.new()
	bullet_mm.multimesh = mm
	bullet_mm.texture = ImageTexture.create_from_image(img)
	bullet_mm.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	bullet_mm.show_behind_parent = true
	add_child(bullet_mm)


func start() -> void:
	arena_rect = Rect2(Vector2.ZERO, get_viewport_rect().size)

	var center_x := arena_rect.get_center().x
	boss.position = Vector2(center_x, arena_rect.position.y + boss_y_offset)
	target_x = center_x
	move_timer = 30
	invuln = 0.0
	visible = true

	await _intro()

	boss.set_active(true)
	_set_hitbox_visible(true)
	active = true
	_start_pattern(0)


func _intro() -> void:
	boss.modulate.a = 0.0
	if player:
		player.set("bullet_hell_mode", true)
		player.set("velocity", Vector2.ZERO)
		player.process_mode = Node.PROCESS_MODE_DISABLED

	var t := create_tween()

	var pulse := freeze_time / 6.0
	for i in 3:
		t.tween_method(_set_warning, 0.0, 0.35, pulse)
		t.tween_method(_set_warning, 0.35, 0.0, pulse)

	var from := player.global_position if player else Vector2.ZERO
	var to := to_global(arena_rect.get_center())
	t.tween_method(_lerp_player.bind(from, to), 0.0, 1.0, lerp_time) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	t.parallel().tween_property(boss, "modulate:a", 1.0, lerp_time)

	await t.finished

	if player:
		player.process_mode = Node.PROCESS_MODE_INHERIT


func _set_warning(a: float) -> void:
	warning_alpha = a
	queue_redraw()


func _lerp_player(w: float, from: Vector2, to: Vector2) -> void:
	if player:
		player.global_position = from.lerp(to, w)


func _set_hitbox_visible(on: bool) -> void:
	if not player:
		return

	if not is_instance_valid(hitbox_dot):
		hitbox_dot = Node2D.new()
		hitbox_dot.z_index = 100
		hitbox_dot.z_as_relative = false
		hitbox_dot.draw.connect(_draw_hitbox)
		player.add_child(hitbox_dot)

	hitbox_dot.position = hitbox_offset
	hitbox_dot.visible = on
	hitbox_dot.queue_redraw()


func _draw_hitbox() -> void:
	hitbox_dot.draw_circle(Vector2.ZERO, dot_radius + 1.0, Color(1, 1, 1, 0.5))
	hitbox_dot.draw_circle(Vector2.ZERO, dot_radius, Color(1, 0, 0, 0.5))


func _clamp_player() -> void:
	if not player:
		return
	var bounds := arena_rect.grow(-player_margin)
	var p := to_local(player.global_position).clamp(bounds.position, bounds.end)
	player.global_position = to_global(p)


func _start_pattern(index: int) -> void:
	phase = index
	var pattern : Dictionary = patterns[index]

	boss.max_health = pattern["health"]
	boss.health = pattern["health"]
	phase_time = pattern["time"]
	shot_timer = 1.0
	spiral_angle = 0.0
	_clear_bullets()


func _next_pattern() -> void:
	if not active:
		return

	if phase + 1 >= patterns.size():
		_end(true)
	else:
		_start_pattern(phase + 1)


func _physics_process(delta: float) -> void:
	if not active:
		return

	_clamp_player()

	phase_time -= delta
	if phase_time <= 0.0:
		_next_pattern()
		return

	_move_boss(delta)

	var shoot : Callable = patterns[phase]["fn"]
	shoot.call(delta, patterns[phase])

	_move_bullets(delta)
	_render_bullets()
	queue_redraw()


func _move_boss(delta: float) -> void:
	move_timer -= delta
	if move_timer <= 0.0:
		target_x = randf_range(arena_rect.position.x + 60.0, arena_rect.end.x - 60.0)
		move_timer = randf_range(25.0, 30.0)

	boss.position.x = move_toward(boss.position.x, target_x, boss_move_speed * delta)
	boss.position.y = arena_rect.position.y + boss_y_offset


func _pattern_ring(delta: float, p: Dictionary) -> void:
	shot_timer -= delta
	if shot_timer > 0.0:
		return

	_ring(p.get("count", 24), p.get("speed", 140.0), randf() * TAU)
	shot_timer = p.get("interval", 1.2)


func _pattern_spiral(delta: float, p: Dictionary) -> void:
	shot_timer -= delta
	if shot_timer > 0.0:
		return

	var arms : int = p.get("arms", 2)
	var speed : float = p.get("speed", 170.0)

	spiral_angle += p.get("turn", 0.35)
	for i in arms:
		_fire(boss.position, Vector2.from_angle(spiral_angle + TAU * i / arms) * speed)

	shot_timer = p.get("interval", 0.07)


func _pattern_aimed(delta: float, p: Dictionary) -> void:
	shot_timer -= delta
	if shot_timer > 0.0:
		return

	var shots : int = p.get("shots", 5)
	var spread : float = p.get("spread", 0.22)
	var speed : float = p.get("speed", 220.0)
	var ring_count : int = p.get("ring_count", 16)

	var dir : Vector2 = (_player_local() - boss.position).normalized()
	for i in shots:
		var offset := (i - (shots - 1) / 2.0) * spread
		_fire(boss.position, dir.rotated(offset) * speed)

	if ring_count > 0:
		_ring(ring_count, p.get("ring_speed", 90.0), randf() * TAU)

	shot_timer = p.get("interval", 0.8)


func _ring(count: int, speed: float, offset: float) -> void:
	for i in count:
		var angle := offset + TAU * i / count
		_fire(boss.position, Vector2.from_angle(angle) * speed)


func _fire(pos: Vector2, vel: Vector2) -> void:
	if bullet_pos.size() >= max_bullets:
		return
	bullet_pos.append(pos)
	bullet_vel.append(vel)


func _clear_bullets() -> void:
	bullet_pos.clear()
	bullet_vel.clear()
	bullet_mm.multimesh.visible_instance_count = 0


func _move_bullets(delta: float) -> void:
	invuln = max(0.0, invuln - delta)

	var hit_pos := _player_local()
	var hit_dist := dot_radius + bullet_radius
	var hit_sq := hit_dist * hit_dist
	var keep_area := arena_rect.grow(40)
	var hurt := false

	for i in range(bullet_pos.size() - 1, -1, -1):
		var p := bullet_pos[i] + bullet_vel[i] * delta
		var dead := not keep_area.has_point(p)

		if not dead and p.distance_squared_to(hit_pos) < hit_sq:
			dead = true
			hurt = true

		if dead:
			var last := bullet_pos.size() - 1
			bullet_pos[i] = bullet_pos[last]
			bullet_vel[i] = bullet_vel[last]
			bullet_pos.resize(last)
			bullet_vel.resize(last)
		else:
			bullet_pos[i] = p

	if hurt and invuln <= 0.0 and player and player.has_method("hit"):
		player.hit(1)
		invuln = 1.0


func _render_bullets() -> void:
	var mm := bullet_mm.multimesh
	var n := bullet_pos.size()
	mm.visible_instance_count = n
	for i in n:
		mm.set_instance_transform_2d(i, Transform2D(0.0, bullet_pos[i]))


func _player_local() -> Vector2:
	if is_instance_valid(hitbox_dot):
		return to_local(hitbox_dot.global_position)
	if not player:
		return Vector2.ZERO
	return to_local(player.global_position)


func _end(won: bool) -> void:
	active = false
	_clear_bullets()
	boss.set_active(false)
	_set_hitbox_visible(false)
	visible = false

	if player:
		player.set("bullet_hell_mode", false)

	finished.emit(won)
	queue_redraw()


func _draw() -> void:
	if warning_alpha > 0.0:
		draw_rect(arena_rect, Color(1, 0, 0, warning_alpha))
		draw_string(ThemeDB.fallback_font, Vector2(arena_rect.position.x, arena_rect.get_center().y),
			"WARNING", HORIZONTAL_ALIGNMENT_CENTER, arena_rect.size.x, 32,
			Color(1, 1, 1, minf(1.0, warning_alpha * 3.0)))

	if not active:
		return

	var ratio : float = clampf(float(boss.health) / float(boss.max_health), 0.0, 1.0)
	var bar_pos := Vector2(arena_rect.position.x + 20.0, arena_rect.position.y + 10.0)
	var bar_size := Vector2(arena_rect.size.x - 40.0, 8.0)

	draw_rect(Rect2(bar_pos, bar_size), Color(0.2, 0.0, 0.0))
	draw_rect(Rect2(bar_pos, Vector2(bar_size.x * ratio, bar_size.y)), Color.RED)
