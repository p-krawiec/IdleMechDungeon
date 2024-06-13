extends State
class_name EnemyState

var parent: BaseEnemy
var player: Player

var distance_to_player: float

func die():
	transition_to.emit(self, "EnemyDie")
	
func get_distance_to_player():
	return parent.position.distance_to(player.position)
