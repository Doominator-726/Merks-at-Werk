extends Node2D

var stations_cleared = false
@onready var World = $World

func _ready() -> void:
	
	pass

func _process(_delta: float) -> void:
	if !stations_cleared and len(get_tree().get_nodes_in_group("station")) == 0:
		stations_cleared = true

	for copy in $CopiedEntities.get_children():
		copy.queue_free()
		
	for entity in get_tree().get_nodes_in_group("looping_entity"):
			
		if !is_instance_valid(entity):
			return
			
		if "speed" in entity and entity.speed != 0:
			if entity.global_position.x >= Globals.map_bounds.end[0]:
				entity.global_position.x -= Globals.map_size.x
			elif entity.global_position.x < Globals.map_bounds.position[0]:
				entity.global_position.x += Globals.map_size.x
			if entity.global_position.y >= Globals.map_bounds.end[1]:
				entity.global_position.y -= Globals.map_size.y
			elif entity.global_position.y < Globals.map_bounds.position[1]:
				entity.global_position.y += Globals.map_size.y
			
		if !entity.is_in_group("player") and entity.get_parent() != $CopiedEntities:
			var new_entity = entity.get_sprite().duplicate()
			
			if Globals.player_position.x >= 0:
				if entity.global_position.x <= 0:
					new_entity.global_position = entity.global_position + Vector2(World.map_size.x, 0)
					$CopiedEntities.add_child(new_entity)
			else:
				if entity.global_position.x > 0:
					new_entity.global_position = entity.global_position - Vector2(World.map_size.x, 0)
					$CopiedEntities.add_child(new_entity)
			
			new_entity = entity.get_sprite().duplicate()
			
			if Globals.player_position.y >= 0:
				if entity.global_position.y <= 0:
					new_entity.global_position = entity.global_position + Vector2(0, World.map_size.y)
					$CopiedEntities.add_child(new_entity)
			else:
				if entity.global_position.y > 0:
					new_entity.global_position = entity.global_position - Vector2(0, World.map_size.y)
					$CopiedEntities.add_child(new_entity)
