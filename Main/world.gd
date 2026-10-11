extends Node

var levels : Array[String] = [
	"res://Levels/level1.tscn",
	"res://Levels/level2.tscn",
	"res://Levels/level3.tscn",
	"res://Levels/level4.tscn"
]

var current_level_index : int = 0
var current_level = 1
var current_field
var map_size : Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_field(0)

func load_level(index : int):
	if 0 <= index and index < levels.size():
		if current_level:
			current_level.queue_free()
		current_level = load(levels[index])
		add_child(current_level)
func load_field(index : int):
	if index == 0:
		if current_field:
			current_field.queue_free()
		current_field = load("res://Levels/demo_field.tscn").instantiate()
		print("demo_field loaded")
	elif 1 <= index and index < INF:
		if current_field:
			current_field.queue_free()
		var current_level_string = str(current_level).pad_zeros(2);
		var index_string = str(index)
		var current_field_filename = "res://Levels/" + current_level_string + "/field_" + index_string + ".tscn"
		print(current_field_filename)
		current_field = load(current_field_filename).instantiate()
	add_child(current_field)
	map_size = current_field.map_size
	print("%d loaded" % index)
