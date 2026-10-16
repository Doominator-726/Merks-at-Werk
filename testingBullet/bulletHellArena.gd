class_name BulletHellArena
extends Node2D

signal finished(won: bool)

@export var player : Node2D
@export var arena_rect : Rect2 = Rect2(-320, -240, 640, 480)
@export var boss_y_offset : float = 100.0
@export var boss_move_speed : float = 120.0
@export var player_hit_radius : float = 6.0
@export var bullet_radius : float = 5.0

@onready var boss : Boss = $Boss

var patterns : Array = []
var phase : int = 0
var phase_time : float = 0.0
var bullets : Array = []
var active : bool = false
var shot_timer : float = 0.0
var spiral_angle : float = 0.0
var invuln : float = 0.0
var move_timer : float = 0.0
var target_x : float = 0.0


func _ready() -> void:
	visible = false
	boss.died.connect(_next_pattern)
	boss.set_active(false)

	patterns = [
		{"health": 40, "time": 30.0, "fn": _pattern_ring},
		{"health": 60, "time": 35.0, "fn": _pattern_spiral},
		{"health": 80, "time": 40.0, "fn": _pattern_aimed},
	]

	start.call_deferred()


func start() -> void:
	arena_rect = Rect2(Vector2.ZERO, get_viewport_rect().size)

	if player:
		player.set("bullet_hell_mode", true)

	var center_x := arena_rect.get_center().x
	boss.position = Vector2(center_x, arena_rect.position.y + boss_y_offset)
	target_x = center_x
	move_timer = 3.0
	boss.set_active(true)

	invuln = 0.0
	visible = true
	active = true
	_start_pattern(0)


func _start_pattern(index: int) -> void:
	phase = index
	var pattern : Dictionary = patterns[index]

	boss.max_health = pattern["health"]
	boss.health = pattern["health"]
	phase_time = pattern["time"]
	shot_timer = 1.0
	spiral_angle = 0.0
	bullets.clear()


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

	phase_time -= delta
	if phase_time <= 0.0:
		_next_pattern()
		return

	_move_boss(delta)

	var shoot : Callable = patterns[phase]["fn"]
	shoot.call(delta)

	_move_bullets(delta)
	queue_redraw()


func _move_boss(delta: float) -> void:
	move_timer -= delta
	if move_timer <= 0.0:
		target_x = randf_range(arena_rect.position.x + 60.0, arena_rect.end.x - 60.0)
		move_timer = randf_range(25.0, 30.0)

	boss.position.x = move_toward(boss.position.x, target_x, boss_move_speed * delta)
	boss.position.y = arena_rect.position.y + boss_y_offset


func _pattern_ring(delta: float) -> void:
	shot_timer -= delta
	if shot_timer > 0.0:
		return

	_ring(24, 140.0, randf() * TAU)
	shot_timer = 1.2


func _pattern_spiral(delta: float) -> void:
	shot_timer -= delta
	if shot_timer > 0.0:
		return

	spiral_angle += 0.35
	_fire(boss.position, Vector2.from_angle(spiral_angle) * 170.0)
	_fire(boss.position, Vector2.from_angle(spiral_angle + PI) * 170.0)
	shot_timer = 0.07


func _pattern_aimed(delta: float) -> void:
	shot_timer -= delta
	if shot_timer > 0.0:
		return

	var to_player : Vector2 = _player_local() - boss.position
	for i in range(-2, 3):
		_fire(boss.position, to_player.normalized().rotated(i * 0.22) * 220.0)

	_ring(16, 90.0, randf() * TAU)
	shot_timer = 0.8


func _ring(count: int, speed: float, offset: float) -> void:
	for i in count:
		var angle := offset + TAU * i / count
		_fire(boss.position, Vector2.from_angle(angle) * speed)


func _fire(pos: Vector2, vel: Vector2) -> void:
	bullets.append({"pos": pos, "vel": vel})


func _move_bullets(delta: float) -> void:
	invuln = max(0.0, invuln - delta)

	var player_pos : Vector2 = _player_local()
	var hit_dist : float = player_hit_radius + bullet_radius
	var keep_area : Rect2 = arena_rect.grow(40)

	for i in range(bullets.size() - 1, -1, -1):
		var bullet = bullets[i]
		bullet.pos += bullet.vel * delta

		if not keep_area.has_point(bullet.pos):
			bullets.remove_at(i)
			continue

		if bullet.pos.distance_to(player_pos) < hit_dist:
			bullets.remove_at(i)
			if invuln <= 0.0 and player and player.has_method("hit"):
				player.hit(1)
				invuln = 1.0


func _player_local() -> Vector2:
	if not player:
		return Vector2.ZERO
	return to_local(player.global_position)


func _end(won: bool) -> void:
	active = false
	bullets.clear()
	boss.set_active(false)
	visible = false

	if player:
		player.set("bullet_hell_mode", false)

	finished.emit(won)
	queue_redraw()


func _draw() -> void:
	for bullet in bullets:
		draw_circle(bullet.pos, bullet_radius, Color.WHITE)
		draw_circle(bullet.pos, bullet_radius - 2, Color.HOT_PINK)

	if not active:
		return

	var ratio : float = clampf(float(boss.health) / float(boss.max_health), 0.0, 1.0)
	var bar_pos := Vector2(arena_rect.position.x + 20.0, arena_rect.position.y + 10.0)
	var bar_size := Vector2(arena_rect.size.x - 40.0, 8.0)

	draw_rect(Rect2(bar_pos, bar_size), Color(0.2, 0.0, 0.0))
	draw_rect(Rect2(bar_pos, Vector2(bar_size.x * ratio, bar_size.y)), Color.RED)
