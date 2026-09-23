extends AnimatedSprite2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	sprite_frames.set_animation_loop("explosion", false)
	play("explosion") # Replace with function body.

func _on_animation_finished() -> void:
	queue_free()
