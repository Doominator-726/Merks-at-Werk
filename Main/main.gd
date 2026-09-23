extends Node2D

@onready var level_container = $LevelContainer
var current_level

signal level_clear

func _ready() -> void:
	pass

var stations_cleared = false
func _process(delta: float) -> void:
	if !stations_cleared and len(get_tree().get_nodes_in_group("station")) == 0:
		stations_cleared = true
		
