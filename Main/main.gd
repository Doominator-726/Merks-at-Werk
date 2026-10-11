extends Node2D

var stations_cleared = false
@onready var World = $World

func _ready() -> void:
	
	pass

func _process(_delta: float) -> void:
	if !stations_cleared and len(get_tree().get_nodes_in_group("station")) == 0:
		stations_cleared = true
		
	for copy in $"Copied Entities".get_children():
		copy.queue_free()
		
	for entity in get_tree().get_nodes_in_group("looping_entity"):
			
		if "speed" in entity and entity.speed != 0:
			if entity.global_position.x >= Globals.bounds_positive.x:
				entity.global_position.x = Globals.bounds_negative.x
			elif entity.global_position.x <= Globals.bounds_negative.x:
				entity.global_position.x = Globals.bounds_positive.x
			if entity.global_position.y <= Globals.bounds_positive.y:
				entity.global_position.y = Globals.bounds_negative.y
			elif entity.global_position.y >= Globals.bounds_negative.y:
				entity.global_position.y = Globals.bounds_positive.y
			
		if !entity.is_in_group("player") and entity.get_parent() != $"Copied Entities":
			var new_entity = entity.get_sprite().duplicate()
			
			if Globals.player_position.x >= 0:
				if entity.global_position.x <= 0:
					new_entity.global_position = entity.global_position + Vector2(World.map_size.x, 0)
					$"Copied Entities".add_child(new_entity)
			else:
				if entity.global_position.x > 0:
					new_entity.global_position = entity.global_position - Vector2(World.map_size.x, 0)
					$"Copied Entities".add_child(new_entity)
			
			new_entity = entity.get_sprite().duplicate()
			
			if Globals.player_position.y >= 0:
				if entity.global_position.y <= 0:
					new_entity.global_position = entity.global_position + Vector2(0, World.map_size.y)
					$"Copied Entities".add_child(new_entity)
			else:
				if entity.global_position.y > 0:
					new_entity.global_position = entity.global_position - Vector2(0, World.map_size.y)
					$"Copied Entities".add_child(new_entity)
					
