extends CharacterBody2D

@export var speed: int = 300
@export var health: int = 5
var direction: Vector2 = Vector2(1, 0)

@export var bullet_scene: PackedScene

func _ready() -> void:
	if speed != 0:
		$DirectionTimer.start()
		
func _physics_process(delta: float) -> void:
	
	if speed != 0:
		velocity = direction * speed
		var collision = move_and_collide(velocity * delta)
		if collision:
			var collider = collision.get_collider()
			if collider.is_in_group("player"):
				collider.player_hit(0)
				explode()
	
func _on_direction_timer_timeout() -> void:
	direction.x = randi_range(-1, 1)
	direction.y = randi_range(-1, 1)
	
	if direction.x == 0 and direction.y == 0:
		direction = Vector2(1, 0)
		
func _on_shoot_timer_timeout() -> void:
	if bullet_scene == null:
		return
		
	var bullet = bullet_scene.instantiate()
			
	bullet.global_position = global_position
	bullet.axis = (Globals.player_position - bullet.global_position).normalized()
	
	get_tree().current_scene.add_child(bullet)
			
func explode():
	queue_free()
	
func enemy_hit(damage):
	health -= damage
	if health <= 0:
		queue_free()

func get_sprite():
	return $Sprite2D
