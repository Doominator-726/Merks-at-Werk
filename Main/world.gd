extends Node

var levels : Array[String] = [
	"00",
	"01",
	"02",
]
var level_field_counts: Array[int] = [
	1,
	3,
	8,
]


var current_level
var current_level_index: int = 1
var current_field
var current_field_index: int = 0
var map_size : Vector2



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	current_level_index = 1
	load_field(1)

func load_level(index : int):
	if 0 <= index and index < levels.size():
		if current_field:
			current_field.queue_free()
		current_level_index = index
		current_field_index = 0
		load_field(current_field_index)
func load_field(index : int):
	if index == -1:
		if current_field:
			current_field.queue_free()
		current_field = load("res://Levels/demo_field2.tscn").instantiate()
		print("demo_field2 loaded")
	elif 0 <= index and index < level_field_counts[current_level_index] + 1:
		if current_field:
			current_field.queue_free()
		var current_field_filename = get_field(index)
		print(current_field_filename)
		current_field = load(current_field_filename).instantiate()
		current_field_index = index
		print("%d loaded" % current_field_index)
	else:
		return
	add_child(current_field)
	map_size = current_field.map_size
	current_field.field_clear.connect(next_field)

func next_field():
	print("My child's name is ", get_children()[0].name)
	if not is_demo_field():
		load_field(current_field_index + 1)
		
func get_level(index: int):
	return "res://Levels/%02d/" % [index]
	
func get_field(index: int):
	return get_level(current_level_index) + "/field_%d.tscn" % [index]
	
func is_demo_field():
	return get_children()[0].name.contains("Demo")
