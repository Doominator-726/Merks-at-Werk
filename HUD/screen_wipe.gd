class_name ScreenWipe
extends CanvasLayer

@export var duration: float = 0.4
@onready var rect: ColorRect = $ColorRect


func cover() -> void:
	var h := get_viewport().get_visible_rect().size.y
	rect.position.y = -h
	rect.visible = true
	var t := create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	t.tween_property(rect, "position:y", 0.0, duration)
	await t.finished


func reveal() -> void:
	var h := get_viewport().get_visible_rect().size.y
	var t := create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	t.tween_property(rect, "position:y", h, duration)
	await t.finished
	rect.visible = false
