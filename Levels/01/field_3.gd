extends BaseField


func _ready():
	super()


func _process(_delta: float) -> void:
	super(_delta)
	print(field_timer.time_left)


func _on_field_timer_timeout() -> void:
	pass
