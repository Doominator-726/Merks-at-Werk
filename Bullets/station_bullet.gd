extends Bullet

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	super(delta)
	
func _on_area_entered(area: Area2D) -> void:
	super._on_BaseBullet_area_entered(area)
	
func _on_body_entered(body: Node2D) -> void:
	super._on_BaseBullet_body_entered(body)

func get_sprite():
	return $Sprite2D
