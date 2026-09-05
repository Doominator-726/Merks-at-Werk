extends CharacterBody2D


const SPEED = 0

@onready var state = "demo"
@onready var axis = Vector2.ZERO
@onready var health = 1
func _physics_process(delta: float) -> void:
	if state == "demo":
		pass

func enemy_hit(damage):
	health -= damage
	if health <= 0:
		queue_free()
