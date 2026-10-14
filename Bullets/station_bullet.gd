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
