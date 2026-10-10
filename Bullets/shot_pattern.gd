extends Resource
class_name ShotPattern

@export var pattern_name : String = "Default"
@export var bullet_scene : PackedScene
@export var firing_rate  : float = 0.3
@export var bullet_count : int = 1
@export var spread_angle : float = 0 #in degrees
var Bullet = preload("res://Bullets/base_bullet.gd")

func fire(spawn_pos: Vector2, base_angle, tree_root):
	if bullet_count == 0 or firing_rate == 0:
		return
	if not bullet_scene:
		return
		
	var start_angle = base_angle - spread_angle / 2
	var angle_step = spread_angle if bullet_count == 1 else spread_angle / (bullet_count - 1)
	var current_angle = start_angle
	for i in range(bullet_count):
		var bullet = bullet_scene.instantiate()
		bullet.global_position = spawn_pos
		bullet.axis = Vector2.from_angle(current_angle)
		bullet.rotation_degrees = current_angle
		tree_root.add_child(bullet)
		current_angle += angle_step
