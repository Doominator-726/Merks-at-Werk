class_name BaseField
extends Node2D

@export var map_size : Vector2 = Vector2(2560, 2560)
@export var spawn_positon : Vector2 = Vector2.ZERO
@export var bonus_points  : int = 40
@export var timer_enabled : bool = false

@export var missile_scene : PackedScene = preload("res://Enemy/missile_enemy.tscn")

@onready var field_timer: Node = $FieldTimer
@onready var spawn_timer: Node = $SpawnTimer

func _ready():
	Globals.player_position = spawn_positon
	if timer_enabled:
		print("start field timer")
		field_timer.start()
	print("start spawn timer")
	spawn_timer.start()
	
	# Get map size and bounds using tile map.
	var tile_map = $ParallaxBackground/Parallax2D/TileMapLayer
	
	map_size = Vector2(tile_map.get_used_rect().size) * Vector2(tile_map.tile_set.tile_size) * tile_map.scale
	get_parent().map_size = map_size
	$ParallaxBackground/Parallax2D.repeat_size = map_size
	$ParallaxBackground/Parallax2D.scroll_offset = spawn_positon
	
	var end = tile_map.to_global(tile_map.map_to_local(tile_map.get_used_rect().end))
	var start = tile_map.to_global(tile_map.map_to_local(tile_map.get_used_rect().position))
	var bounds_negative = Vector2(start[0], end[1])
	var bounds_positive = Vector2(end[0], start[1])
	get_parent().bounds_positive = bounds_positive
	get_parent().bounds_negative = bounds_negative
	
	$ParallaxBackground/Parallax2D.scroll_offset = spawn_positon
func _process(_delta: float) -> void:
	if timer_enabled:
		Globals.field_time_left = field_timer.time_left
func _on_SpawnTimer_timeout() -> void:
	var missile = missile_scene.instantiate()
	var screen_size = DisplayServer.screen_get_size()
	var edge_pos : Vector2 = screen_size * 3 / 2
	var location = randi() % 4
	match location:
		0:
			edge_pos.x = randi_range(-edge_pos.x, edge_pos.x)
			edge_pos.y = -edge_pos.y #top edge
		1:
			edge_pos.x = randi_range(-edge_pos.x, edge_pos.x)
			edge_pos.y = edge_pos.y #bottom edge
		2:
			edge_pos.x = -edge_pos.x #left edge
			edge_pos.y = randi_range(-edge_pos.y, edge_pos.y)
		3:
			edge_pos.x = edge_pos.x #right edge
			edge_pos.y = randi_range(-edge_pos.y, edge_pos.y)
	missile.global_position = get_viewport().get_camera_2d().global_position + edge_pos
	missile.axis = (Globals.player_position - missile.global_position).normalized()
	missile.look_at(Globals.player_position)
	add_child(missile)
	print("Booyakasha! gp = ", missile.global_position, ", edge = ", edge_pos)
	spawn_timer.start()
