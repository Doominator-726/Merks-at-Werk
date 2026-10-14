extends Bullet

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	super(delta)


func _on_area_entered(area: Area2D, target_method = "hit") -> void:
	super(area)


func _on_body_entered(body: Node2D, target_method = "hit") -> void:
	super(body)


func get_sprite():
	return super()

func _on_despawn_timer_timeout() -> void:
	if is_off_screen:
		print("station_bullet despawned")
		queue_free()


func _on_notifier_screen_entered() -> void:
	if is_off_screen:
		print("station_bullet back on_screen!")
		despawn_timer.stop()
	else:
		print("station_bullet on_screen!")
	is_off_screen = false


func _on_notifier_screen_exited() -> void:
	print("station_bullet off_screen!")
	is_off_screen = true
	despawn_timer.start()
