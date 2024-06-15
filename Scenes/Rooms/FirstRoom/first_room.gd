extends BaseRoom

var tutorial_screen: TutorialScreen
var player: Player

func _ready():
	super()
	player = get_tree().get_first_node_in_group("Player") as Player
	
	if Util.show_tutorial == false:
		$TutorialAreas.queue_free()
	else:
		tutorial_screen = get_tree().get_first_node_in_group("TutorialScreen") as TutorialScreen

func close_gate():
	$TileMap.set_layer_enabled(4, true)

func on_spawnable_area_body_entered(body):
	if not spawnable_area_entered:
		if body is Player:
			close_gate()
			spawnable_area_entered = true
			$SpawnableArea.start()
			


func _on_basic_controls_area_body_entered(body):
	if body is Player:
		tutorial_screen.display_tutorial(1)
		player.allow_input = false
		player.direction = Vector2.ZERO
		$TutorialAreas/BasicControlsArea.queue_free()

func _on_reload_tutorial_area_body_entered(body):
	if body is Player:
		tutorial_screen.display_tutorial(2)
		player.allow_input = false
		player.direction = Vector2.ZERO
		$TutorialAreas/ReloadTutorialArea.queue_free()

func _on_before_fight_area_body_entered(body):
	if body is Player:
		tutorial_screen.display_tutorial(3)
		player.allow_input = false
		player.direction = Vector2.ZERO
		$TutorialAreas/BeforeFightArea.queue_free()
