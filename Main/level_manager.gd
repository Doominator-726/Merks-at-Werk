extends Node

var level_container = $Main.LevelContainer
var levels : Array[String] = [
	"res://Levels/level1.tscn",
	"res://Levels/level2.tscn",
	"res://Levels/level3.tscn",
	"res://Levels/level4.tscn"
]

var current_level_index : int = 0
var current_level : Resource
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if current_level:
		current_level.queue_free()
	current_level = load("res://DemoField/demo_field.tscn")
	level_container.add_child(current_level)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func load_level(index : int):
	if 0 <= index and index < levels.size():
		if current_level:
			current_level.queue_free()
		current_level = load(levels[index])
		level_container.add_child(current_level)
