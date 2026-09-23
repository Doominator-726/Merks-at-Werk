extends Node2D

@export var back_layer: Node2D
@export var front_layer: Node2D
@export var logo: Node2D


@export var back_strength: Vector2 = Vector2(6, 3)
@export var front_strength: Vector2 = Vector2(12, 0)
@export var logo_strength: Vector2 = Vector2(3, 0)

@export var idle_amplitude_back: float = 8.0
@export var idle_amplitude_front: float = 15.0
@export var idle_amplitude_logo: float = 4.0
@export var idle_speed: float = 0.3

@export var smoothing: float = 4.0

@export var back_max_offset: Vector2 = Vector2(15, 8)
@export var front_max_offset: Vector2 = Vector2(25, 0)
@export var logo_max_offset: Vector2 = Vector2(6, 0)

var back_start_pos: Vector2
var front_start_pos: Vector2
var logo_start_pos: Vector2
var time_elapsed: float = 0.0

func _ready() -> void:
	back_start_pos = back_layer.position
	front_start_pos = front_layer.position
	logo_start_pos = logo.position

func _process(delta: float) -> void:
	time_elapsed += delta

	var viewport_size = get_viewport_rect().size
	var mouse_pos = get_viewport().get_mouse_position()
	var mouse_offset = (mouse_pos - viewport_size / 2.0) / (viewport_size / 2.0)

	var back_move =  (-mouse_offset * back_strength)
	var front_move = (-mouse_offset * front_strength)
	var logo_move = (-mouse_offset * logo_strength)

	back_move = back_move.clamp(-back_max_offset, back_max_offset)
	front_move = front_move.clamp(-front_max_offset, front_max_offset)
	logo_move = logo_move.clamp(-logo_max_offset, logo_max_offset)

	var target_back = back_start_pos + back_move
	var target_front = front_start_pos + front_move
	var target_logo = logo_start_pos + logo_move

	back_layer.position = back_layer.position.lerp(target_back, smoothing * delta)
	front_layer.position = front_layer.position.lerp(target_front, smoothing * delta)
	logo.position = logo.position.lerp(target_logo, smoothing * delta)
