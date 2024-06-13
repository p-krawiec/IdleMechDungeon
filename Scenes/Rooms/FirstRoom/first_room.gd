extends BaseRoom

func close_gate():
	$TileMap.set_layer_enabled(4, true)

func on_spawnable_area_body_entered(body):
	if not spawnable_area_entered:
		if(body as Node).is_in_group("Player"):
			close_gate()
			spawnable_area_entered = true
			
			get_tree().get_first_node_in_group("GameMain").clear_enemies()
				
			$SpawnableArea.start()
			
